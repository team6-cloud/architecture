terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
//      version = "~> 4.0.0"
      version = "~> 4.16.0"	// https://stackoverflow.com/questions/73195027/updating-runtime-value-of-aws-lambda-function-module-into-nodejs16
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = ">= 0.14.9"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  profile = "default"
  region = var.aws_region
}

##### Creating a Random String #####
resource "random_string" "random" {
  length = 6
  special = false
  upper = false
} 


#========================================================================
// DynamodDB table
#========================================================================
// -> database.tf	// TODO: 
					// -añadir num random (igual que en s3) para permitir multiples tablas.?

#========================================================================
// S3 bucket
#========================================================================
// -> s3.tf		

#========================================================================
// Resultado del build del frontend -> upload a s3.
#========================================================================
// -> frontend.tf		// TODO: 
						// -establecer dependencias con la creación del bucket y el cloudfront dist.
						// -hacer el copy al bucket s3.
						// -inyectar la variable de entorno para la API (a partir de la url de cloudfront)

#========================================================================
// lambda setup
#========================================================================
// -> lambda.tf		// TODO: subir la version del runtime de node si se requiere
