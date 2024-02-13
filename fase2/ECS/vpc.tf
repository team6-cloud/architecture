module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  name                 = "${var.prefix}-vpc"
  cidr                 = "${var.vpc_addr_prefix}.0.0/16"
  azs                  = ["${var.region}a", "${var.region}b"]
  public_subnets       = ["${var.vpc_addr_prefix}.101.0/24", "${var.vpc_addr_prefix}.201.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = false
}

resource "aws_security_group" "alb" {
  name        = "${var.prefix}-alb-sg"
  description = "Application Load Balancer security group"
  vpc_id      = module.vpc.vpc_id
  ingress {
    protocol    = "tcp"
    from_port   = 3000
    to_port     = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 3001
    to_port     = 3001
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
