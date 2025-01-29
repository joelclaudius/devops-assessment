variable "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "ecr_backend_repo_name" {
  description = "The name of the ECR repository for the backend"
  type        = string
}

variable "ecr_database_repo_name" {
  description = "The name of the ECR repository for the database"
  type        = string
}

variable "ecr_frontend_repo_name" {
  description = "The name of the ECR repository for the frontend"
  type        = string
}

variable "backend_image_tag" {
  description = "The tag for the backend image"
  type        = string
  default     = "latest"
}

variable "frontend_image_tag" {
  description = "The tag for the frontend image"
  type        = string
  default     = "latest"
}

variable "database_image_tag" {
  description = "The tag for the database image"
  type        = string
  default     = "latest"
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}



variable "aws_region" {
  description = "AWS region"
  type        = string
}

