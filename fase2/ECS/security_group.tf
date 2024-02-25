# security group for ALB
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

# security group for tasks
resource "aws_security_group" "ecs_tasks" {
  name = "${var.prefix}-alb-tasks"
  description = "ECS tasks security group"
  vpc_id = module.vpc.vpc_id
  ingress {
    protocol = "tcp"
    from_port = var.frontend_port
    to_port = var.frontend_port
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    protocol = "tcp"
    from_port = var.backend_port
    to_port = var.backend_port
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}