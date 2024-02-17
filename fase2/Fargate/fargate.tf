resource "aws_ecs_cluster" "cluster" {
  name = "fase2-cluster"
  
  tags = {
    CostCenter = "Dev PoC"
    fase       = "2"
	}
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.labrole_arn
  task_role_arn            = var.labrole_arn
  cpu                      = var.frontend_cpu
  memory                   = var.frontend_memory

  container_definitions = jsonencode([
    {
      name         = "frontend_servicename"
      image        = var.frontend_image
      cpu          = var.frontend_cpu
      memory       = var.frontend_memory
      essential    = true
      portMappings = [
        {
          containerPort = var.frontend_port
          hostPort      = var.frontend_port
          protocol      = "tcp"
        }
      ]
	  
	  /*
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          "awslogs-group"         = aws_cloudwatch_log_group.log_group.name,
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "${var.service_name}-log-stream-${var.environment}"
        }
      }  */
    }
  ])

  tags = {
    CostCenter = "Dev PoC"
    fase       = "2"
	}   
}

resource "aws_security_group" "sg_frontend" {
 name        = "sg_frontend"
 description = "Allow 3000 to frontend containers"
 vpc_id      = aws_vpc.vpc.id

ingress {
   description = "Allow tcp/3000 ingress"
   from_port   = var.frontend_port
   to_port     = var.frontend_port
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }

  tags = {
    CostCenter = "Dev PoC"
    fase       = "2"
	}   
}


resource "aws_ecs_task_definition" "backend" {
  family                   = "backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.labrole_arn
  task_role_arn            = var.labrole_arn
  cpu                      = var.backend_cpu
  memory                   = var.backend_memory

  container_definitions = jsonencode([
    {
      name         = "backend_servicename"
      image        = var.backend_image
      cpu          = var.backend_cpu
      memory       = var.backend_memory
      essential    = true
      portMappings = [
        {
          containerPort = var.backend_port
          hostPort      = var.backend_port
          protocol      = "tcp"
        }
      ]
	  
	  /*
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          "awslogs-group"         = aws_cloudwatch_log_group.log_group.name,
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "${var.service_name}-log-stream-${var.environment}"
        }
      }  */
    }
  ])

  tags = {
    CostCenter = "Dev PoC"
    fase       = "2"
	}   
}

resource "aws_security_group" "sg_backend" {
 name        = "sg_backend"
 description = "Allow 3001 to backend containers"
 vpc_id      = aws_vpc.vpc.id

ingress {
   description = "Allow tcp/3001 ingress"
   from_port   = var.backend_port
   to_port     = var.backend_port
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }

  tags = {
    CostCenter = "Dev PoC"
    fase       = "2"
	}   
}

// security group para el balanceador

resource "aws_security_group" "sg_lb" {
 name        = "sg_lb"
 description = "Allow 80 to ALB"
 vpc_id      = aws_vpc.vpc.id

ingress {
   description = "Allow tcp/80 ingress"
   from_port   = var.lb_port
   to_port     = var.lb_port
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }

  tags = {
    CostCenter = "Dev PoC"
    fase       = "2"
	}   
}


resource "aws_lb" "tfm_alb" {
  name            = "tfm-alb"
  subnets         = aws_subnet.public_subnets.*.id
  security_groups = [aws_security_group.sg_lb.id]
}

resource "aws_lb_target_group" "tg_frontend" {
  name        = "tg-frontend"
  port        = var.lb_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
}

resource "aws_lb_target_group" "tg_backend" {
  name        = "tg-backend"
  port        = var.lb_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.tfm_alb.id
  port              = var.lb_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg_frontend.id
    type             = "forward"
  }
}


/*
resource "aws_ecs_service" "frontend_service" {
  name                               = "${var.namespace}_ECS_Service_${var.environment}"
  cluster                            = aws_ecs_cluster.default.id
  task_definition                    = aws_ecs_task_definition.default.arn
  desired_count                      = var.ecs_task_desired_count
  deployment_minimum_healthy_percent = var.ecs_task_deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.ecs_task_deployment_maximum_percent
  launch_type                        = "FARGATE"

  load_balancer {
    target_group_arn = aws_alb_target_group.service_target_group.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_container_instance.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = {
    CostCenter = "Dev PoC"
    fase       = "2"
	}   
  
}


*/