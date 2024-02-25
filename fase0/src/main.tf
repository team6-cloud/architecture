resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(pathexpand("~/.ssh/test.pub"))
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

resource "aws_subnet" "dockercompose" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1a"
}


#EC2 INSTANCES CONFIGURATION

resource "aws_instance" "dockercompose" {
  ami           = "ami-0e731c8a588258d0d"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.dockercompose.id

  vpc_security_group_ids = [aws_security_group.dockercompose.id]
  key_name               = aws_key_pair.deployer.key_name

  tags = {
    Name = "dockercompose-server"
  }

  user_data = <<-EOF
              #!/bin/bash
              # User configuration
              curl -sq https://github.com/${var.github_user}.keys | tee -a /home/${var.system_user}/.ssh/authorized_keys
              # Update the system
              sudo yum update -y
              # Docker installation
              sudo yum install -y docker
              sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              sudo systemctl start docker
              # Package installation
              sudo yum install -y git
              git clone https://github.com/Roballed/docker-frontend-backend-db.git
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

resource "aws_security_group" "dockercompose" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id] # only allow SSH from the bastion host
  }
  ingress {
    from_port   = 3000
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

resource "aws_route_table_association" "dockercompose" {
  subnet_id      = aws_subnet.dockercompose.id
  route_table_id = aws_route_table.private.id
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

resource "aws_lb_listener" "dockercompose" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dockercompose.arn
  }
}

resource "aws_lb_listener_rule" "backend" {
  listener_arn = aws_lb_listener.dockercompose.arn
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

resource "aws_lb_target_group" "dockercompose" {
  name     = "dockercompose-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
  }
}

resource "aws_lb_target_group_attachment" "dockercompose" {
  target_group_arn = aws_lb_target_group.dockercompose.arn
  target_id        = aws_instance.dockercompose.id
  port             = 3000
}

resource "aws_lb_target_group" "backend" {
  name     = "backend-target-group"
  port     = 80
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
  target_id        = aws_instance.dockercompose.id
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

output "ssh_command_dockercompose" {
  description = "The SSH command to connect to the dockercompose host"
  value       = "ssh -A ${var.system_user}@${aws_instance.dockercompose.private_ip}"
}