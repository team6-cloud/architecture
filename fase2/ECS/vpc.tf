module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  name                 = "${var.prefix}-vpc"
  cidr                 = "${var.vpc_addr_prefix}.0.0/16"
  azs                  = ["${var.region}a", "${var.region}b"]
  public_subnets       = ["${var.vpc_addr_prefix}.101.0/24", "${var.vpc_addr_prefix}.201.0/24"]
  private_subnets = ["${var.vpc_addr_prefix}.1.0/24", "${var.vpc_addr_prefix}.10.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = false
}

