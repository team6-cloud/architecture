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
    cpu_architecture        = "X86_64"
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
        "awslogs-create-group": "true",
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
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  container_definitions = <<DEFINITION
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
        "awslogs-create-group": "true",
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
        "awslogs-create-group": "true",
        "awslogs-group": "${aws_cloudwatch_log_group.mongo_log_group.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}
