provider "aws" {	// TODO: buscar la manera de que funcione con la region por defecto.
  region = var.region
}

resource "aws_ecr_repository" "frontend" {
  name = "frontend"          # Name of the repository
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "backend" {
  name = "backend"          # Name of the repository
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
}