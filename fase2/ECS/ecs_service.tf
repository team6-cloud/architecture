# frontend service
resource "aws_ecs_service" "frontend_service" {
  name                               = "frontend-service"
  cluster                            = aws_ecs_cluster.app_cluster.id
  task_definition                    = aws_ecs_task_definition.frontend_task.id
  desired_count                      = var.task_count
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  force_new_deployment               = true
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  network_configuration {
    subnets          = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
    security_groups  = [aws_security_group.ecs_tasks.id]
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
  force_new_deployment               = true
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  network_configuration {
    subnets          = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
    security_groups  = [aws_security_group.ecs_tasks.id]
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