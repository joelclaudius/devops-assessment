
variable "aws_region" {
  description = "AWS region"
  type        = string
  default = "us-east-1"
}

variable "account_id" {
    description = "Account ID"
    default = 670587392556
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  default     = "my-ecs-cluster"
}

variable "ecr_backend_repo_name" {
  description = "Name of the ECR repository for the backend service"
  default     = "my-backend-repo"
}

variable "ecr_frontend_repo_name" {
  description = "Name of the ECR repository for the frontend service"
  default     = "my-frontend-repo"
}

variable "ecr_database_repo_name" {
  description = "Name of the ECR repository for the database service"
  default     = "my-database-repo"
}

