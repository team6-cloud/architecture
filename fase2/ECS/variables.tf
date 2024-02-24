variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "prefix" {
  description = "Prefix used to create the name of the resources"
  type        = string
  default     = "app"
}

variable "vpc_addr_prefix" {
  description = "16 first bits of the VPC prefix"
  type        = string
  default     = "10.0"
}

variable "task-cpu" {
  description = "Task definition CPU value"
  type        = number
  default     = 1024
}

variable "task-memory" {
  description = "Task definition memory value"
  type        = number
  default     = 3072
}

variable "frontend-image" {
  description = "Frontend ECR image URL"
  type        = string
  default     = "654654524281.dkr.ecr.us-west-2.amazonaws.com/frontend:0.1-snapshot"
}

variable "backend-image" {
  description = "Backend ECR image URL"
  type        = string
  default     = "654654524281.dkr.ecr.us-west-2.amazonaws.com/backend:0.1-snapshot"
}

variable "mongo-image" {
  description = "Mongo image"
  type        = string
  default     = "654654524281.dkr.ecr.us-west-2.amazonaws.com/mongo:latest"
}

variable "task_count" {
  description = "Default amount of tasks per service"
  type        = number
  default     = 1
}

variable "labrole_arn" {
  description = "Academy LabRole ARN"
  type        = string
  default     = "arn:aws:iam::654654524281:role/LabRole"
}

variable "frontend_port" {
  description = "Frontend container port"
  type = number
  default = 3000
}

variable "backend_port" {
  description = "Backend container port"
  type = number
  default = 3001
}
