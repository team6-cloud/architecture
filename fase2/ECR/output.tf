output "frontend_repository_url" {
  description = "The URL of the created ECR repository"
  value       = aws_ecr_repository.frontend.repository_url
}

output "backend_repository_url" {
  description = "The URL of the created ECR repository"
  value       = aws_ecr_repository.backend.repository_url
}