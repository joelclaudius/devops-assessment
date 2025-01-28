variable aws_region {
  description = "This is aws region"
  default     = "us-east-1"
  type        = string
}


variable aws_instance_type {
  description = "This is aws ec2 type "
  default = "t2.medium"
  type        = string
}

variable aws_key {
  description = "Key in region"
  default     = "my_ec2_key"
  type        = string
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

