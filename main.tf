/*

 */
 
provider "aws" {
  region = "us-west-2" # Oregon
} 

// VPC publica
resource "aws_vpc" "vpc" {
 cidr_block = "10.0.0.0/20"	# 4096-5
 
 tags = {
   Name = "vpc for TFM-PFP"
   CostCenter = "Dev PoC"
 }
}

// subnets publicas, una por cada AZ
resource "aws_subnet" "public_subnets" {
 count      = length(var.public_subnet_cidrs)
 vpc_id     = aws_vpc.vpc.id
 cidr_block = element(var.public_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Public Subnet ${count.index + 1}"
   CostCenter = "Dev PoC"   
 }
}

// subnets privadas, una por cada AZ
resource "aws_subnet" "private_subnets" {
 count      = length(var.private_subnet_cidrs)
 vpc_id     = aws_vpc.vpc.id
 cidr_block = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Private Subnet ${count.index + 1}"
   CostCenter = "Dev PoC"
 }
}

// IGW en vpc 
resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.vpc.id
 
 tags = {
   Name = " VPC IGW"
   CostCenter = "Dev PoC"   
 }
}

// crear route table adicional para enrutar trafico de las subredes publicas al IGW
resource "aws_route_table" "public_rt" {
 vpc_id = aws_vpc.vpc.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
 
 tags = {
   Name = "Route Table"
   Desc = "RT to grant access from public subnets to the internet"
   CostCenter = "Dev PoC"
 }
}

// asociar la route table a las subredes publicas:
resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.public_rt.id
}


//////////////////////////////////////////////

// NATGW en las subredes publicas de la vpc publica
// extender a todas las subredes publicas?
// hay que pedir explicitamente una elastic ip para los natgws?
resource "aws_eip" "nat_gateway" {
  count = length(var.public_subnet_cidrs)
#  vpc = true // error raro con IAM.
  tags = {
    Name = "EIP para los NATGW ${count.index}"
  }
}

// NATGW en subnet(s) publica(s)
resource "aws_nat_gateway" "nat_gateway" {
  count = length(var.public_subnet_cidrs)
  allocation_id = element(aws_eip.nat_gateway[*].id, count.index)
  subnet_id = element(aws_subnet.public_subnets[*].id, count.index)
  #subnet_id = aws_subnet.nat_gateway.id
  # aws_subnet.nat_gateway.id
  tags = {
    "Name" = "Public NAT GW ${count.index} in public subnet, public vpc"
  }
}

// tablas de enrutamiento para las subnets privadas
resource "aws_route_table" "rt_natgw" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gateway[*].id, count.index)
  }
  tags = {
    "Name" = "Route table ${count.index} in private subnet, public vpc"
  }
}

// asociar las route table a las subredes privadas de la vpc publica:
resource "aws_route_table_association" "public_private_subnet_asso" {
 count = length(var.private_subnet_cidrs)
 subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
 route_table_id = element(aws_route_table.rt_natgw[*].id, count.index)
}
