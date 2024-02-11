/* 

tercer digito de la IP:
        impar: subnet publica
        par: subnet privada

*/

// region por defecto
variable "region" {
  type        = string
  description = "default AWS Region"
  default     = "us-west-2"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC network"
  default     = "10.0.0.0/20"
  type        = string
}

// definir sobre que AZ pasamos las subnets.
variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["a", "b"]
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


// referencia a IAM role "LabRole"
variable "labrole_arn" {
	type = string
	default = "arn:aws:iam::851725525762:role/LabRole"
}

////////////////////////////
// configuración frontend //
////////////////////////////

variable "frontend_cpu" {
	type = number
	default = 2048
}

variable "frontend_memory" {
	type = number
	default = 4096
}

variable "frontend_port" {
	type = number
	default = 3000
}


variable "frontend_image" {
	type = string
	default = "851725525762.dkr.ecr.us-west-2.amazonaws.com/frontend:0.1-snapshot"
}


////////////////////////////
// configuración backend //
////////////////////////////

variable "backend_cpu" {
	type = number
	default = 2048
}

variable "backend_memory" {
	type = number
	default = 4096
}

variable "backend_port" {
	type = number
	default = 3001
}

variable "backend_image" {
	type = string
	default = "851725525762.dkr.ecr.us-west-2.amazonaws.com/backend:0.1-snapshot"	
}


variable "lb_port" {
	type = number
	default = 80
}
