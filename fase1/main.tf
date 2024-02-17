provider "aws" {
  region = "us-east-1"
}

variable "system_default_user" {
  description = "EC2 instance default user"
  type        = string
  default     = "ec2-user"
}

variable "system_user" {
  description = "EC2 instance user"
  type        = string
  default     = "ec2-user"
}

variable "github_user" {
  description = "GitHub user, to retrieve the public ssh keys"
  type        = string
  default     = "omarjesusperezortiz"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

#SUBNETS CONFIGURATION

resource "aws_subnet" "bastion" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "frontend" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "backend" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1b"
}

#EC2 INSTANCES CONFIGURATION

resource "aws_instance" "frontend" {
  ami           = "ami-0e731c8a588258d0d"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.frontend.id

  vpc_security_group_ids = [aws_security_group.frontend.id]
  key_name               = aws_key_pair.deployer.key_name

  tags = {
    Name = "frontend-server"
  }

  user_data = <<-EOF
              #!/bin/bash
              # User configuration
              curl -sq https://github.com/${var.github_user}.keys | tee -a /home/${var.system_user}/.ssh/authorized_keys
              # Update the system
              sudo yum update -y
              # Docker installation
              sudo yum install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              # Package installation
              sudo yum install -y git
              EOF
}

resource "aws_instance" "backend" {
  ami           = "ami-0e731c8a588258d0d"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.backend.id

  vpc_security_group_ids = [aws_security_group.backend.id]
  key_name               = aws_key_pair.deployer.key_name

  tags = {
    Name = "backend-server"
  }

  user_data = <<-EOF
              #!/bin/bash
              # User configuration
              curl -sq https://github.com/${var.github_user}.keys | tee -a /home/${var.system_user}/.ssh/authorized_keys
              # Update the system
              sudo yum update -y
              # Docker installation
              sudo yum install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              # Package installation
              sudo yum install -y git
              EOF

}

resource "aws_instance" "bastion" {
  ami           = "ami-0e731c8a588258d0d"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.bastion.id
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name = "bastion-host"
  }

  user_data = <<-EOF
              #!/bin/bash
              # User configuration
              curl -sq https://github.com/${var.github_user}.keys | tee -a /home/${var.system_user}/.ssh/authorized_keys
              EOF
}

#SECURITY GROUPS CONFIGURATION

resource "aws_security_group" "lb" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "frontend" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id] # only allow SSH from the bastion host
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.lb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # adjust this to restrict outbound traffic
  }
}

resource "aws_security_group" "backend" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id] # only allow SSH from the bastion host
  }
  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    security_groups = [aws_security_group.lb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # adjust this to restrict outbound traffic
  }
}

#GATEWAY CONFIGURATION

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.eip_for_nat.id
  subnet_id     = aws_subnet.bastion.id
}

resource "aws_eip" "eip_for_nat" {
  domain   = "vpc"
}

#ROUTING CONFIGURATION

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route_table_association" "bastion" {
  subnet_id      = aws_subnet.bastion.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "backend" {
  subnet_id      = aws_subnet.backend.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "frontend" {
  subnet_id      = aws_subnet.frontend.id
  route_table_id = aws_route_table.private.id
}

#DATABASE CONFIGURATION

resource "aws_dynamodb_table" "main" {
  name           = "TodosTable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-east-1.dynamodb"
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb" {
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
  route_table_id  = aws_route_table.private.id
}

#LOAD BALANCER CONFIGURATION

resource "aws_lb" "main" {
  name               = "main-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = [aws_subnet.public.id, aws_subnet.bastion.id]

  enable_deletion_protection = false

  tags = {
    Name = "main-lb"
  }
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_listener_rule" "backend" {
  listener_arn = aws_lb_listener.frontend.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

resource "aws_lb_target_group" "frontend" {
  name     = "frontend-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
  }
}

resource "aws_lb_target_group_attachment" "frontend" {
  target_group_arn = aws_lb_target_group.frontend.arn
  target_id        = aws_instance.frontend.id
  port             = 80
}

resource "aws_lb_target_group" "backend" {
  name     = "backend-target-group"
  port     = 3001
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/api/health"
    protocol = "HTTP"
    matcher = "200"
  }
}

resource "aws_lb_target_group_attachment" "backend" {
  target_group_arn = aws_lb_target_group.backend.arn
  target_id        = aws_instance.backend.id
  port             = 3001
}

#OUTPUTS

output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "ssh_command_bastion" {
  description = "The SSH command to connect to the bastion host"
  value       = "ssh -A ${var.system_user}@${aws_instance.bastion.public_ip}"
}

output "ssh_command_backend" {
  description = "The SSH command to connect to the backend host"
  value       = "ssh -A ${var.system_user}@${aws_instance.backend.private_ip}"
}

output "ssh_command_frontend" {
  description = "The SSH command to connect to the frontend host"
  value       = "ssh -A ${var.system_user}@${aws_instance.frontend.private_ip}"
}