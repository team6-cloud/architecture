resource "aws_cloudwatch_log_group" "frontend_log_group" {
  name              = "/${var.prefix}-frontend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "backend_log_group" {
  name              = "/${var.prefix}-backend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "mongo_log_group" {
  name              = "/${var.prefix}-mongo"
  retention_in_days = 7
}