/* 

tercer digito de la IP:
	par: subnet privada
	impar: subnet publica

*/

// definir sobre que AZ pasamos las subnets.
variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["us-west-2a", "us-west-2b"]		// TODO: AZs a y b de la región actual.
}


// direccionamiento de todas las subnets
variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.3.0/24"]
}
 
variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.12.0/24", "10.0.14.0/24"]
}