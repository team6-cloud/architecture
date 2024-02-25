variable "system_default_user" {
  description = "EC2 instance default user"
  type        = string
  default     = "ec2-user"
}

variable "system_user" {
  description = "EC2 instance user"
  type        = string
  default     = "ec2-user"
}

variable "github_user" {
  description = "GitHub user, to retrieve the public ssh keys"
  type        = string
  default     = "Roballed"
}
