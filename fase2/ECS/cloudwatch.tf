resource "aws_cloudwatch_log_group" "frontend_log_group" {
  name              = "/ecs/${var.prefix}-frontend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "backend_log_group" {
  name              = "/ecs/${var.prefix}-backend"
  retention_in_days = 7
}