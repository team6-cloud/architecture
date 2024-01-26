provider "aws" {
#  region = data.aws_region.current.name
  region = "us-east-1"
#  region  = local.aws_region

}

resource "aws_ecr_repository" "todo" {
  name = "todo"          # Name of the repository
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
}

/*
resource "aws_ecr_repository" "backend" {
  name = "docker-backend"          # Name of the repository
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
} */