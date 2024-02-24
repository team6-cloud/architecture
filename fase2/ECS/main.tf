# alb
resource "aws_lb" "app-alb" {
  name                       = "app-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
  enable_deletion_protection = false
}

resource "aws_lb" "backend-alb" {
  name                       = "backend-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
  enable_deletion_protection = false
}

# target groups
resource "aws_alb_target_group" "frontend_tg" {
  name        = "frontend-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 2
    interval            = 30
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = 3
    path                = "/"
  }
}

resource "aws_alb_target_group" "backend_tg" {
  name        = "backend-tg"
  port        = 3001
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 2
    interval            = 30
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = 3
    path                = "/api"
  }
}

# listeners
resource "aws_alb_listener" "frontend-listener" {
  load_balancer_arn = aws_lb.app-alb.id
  port              = 3000
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.frontend_tg.arn
  }
}

resource "aws_alb_listener" "backend-listener" {
  load_balancer_arn = aws_lb.app-alb.id
  port              = 3001
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.backend_tg.arn
  }
}

# cluster
resource "aws_ecs_cluster" "app_cluster" {
  name = "app-cluster"
}

# frontend task definition
resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task-cpu
  memory                   = var.task-memory
  execution_role_arn       = var.labrole_arn
  task_role_arn            = var.labrole_arn
  runtime_platform {
    cpu_architecture = "X86_64"
    operating_system_family = "LINUX"
  }
  container_definitions = <<DEFINITION
[
  {
    "name": "frontend",
    "image": "${var.frontend-image}",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 3000,
        "hostPort": 3000
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.frontend_log_group.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}

# backend task definition
resource "aws_ecs_task_definition" "backend_task" {
  family                   = "backend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task-cpu
  memory                   = var.task-memory
  execution_role_arn       = var.labrole_arn
  task_role_arn            = var.labrole_arn
  runtime_platform {
    cpu_architecture = "X86_64"
    operating_system_family = "LINUX"
  }
  container_definitions    = <<DEFINITION
[
  {
    "name": "backend",
    "image": "${var.backend-image}",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 3001,
        "hostPort": 3001
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.backend_log_group.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  },
  {
    "name": "mongo",
    "image": "${var.mongo-image}",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 27017,
        "hostPort": 27017
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/mongo",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}

# frontend service
resource "aws_ecs_service" "frontend_service" {
  name                               = "frontend-service"
  cluster                            = aws_ecs_cluster.app_cluster.id
  task_definition                    = aws_ecs_task_definition.frontend_task.id
  desired_count                      = var.task_count
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  network_configuration {
    subnets          = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
    security_groups  = [aws_security_group.alb.id]
    assign_public_ip = false
  }
  load_balancer {
    container_name   = "frontend"
    container_port   = 3000
    target_group_arn = aws_alb_target_group.frontend_tg.id
  }
  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
  depends_on = [aws_lb.app-alb]
}

# backend service
resource "aws_ecs_service" "backend_service" {
  name                               = "backend-service"
  cluster                            = aws_ecs_cluster.app_cluster.id
  task_definition                    = aws_ecs_task_definition.backend_task.id
  desired_count                      = var.task_count
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  network_configuration {
    subnets          = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
    security_groups  = [aws_security_group.alb.id]
    assign_public_ip = false
  }
  load_balancer {
    container_name   = "backend"
    container_port   = 3001
    target_group_arn = aws_alb_target_group.backend_tg.id
  }
  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
  depends_on = [aws_lb.app-alb]
}