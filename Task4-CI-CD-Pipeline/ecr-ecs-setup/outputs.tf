# VPC Output
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main_vpc.id
}

# Subnets Outputs
output "frontend_subnet_id" {
  description = "The ID of the frontend subnet"
  value       = aws_subnet.frontend_subnet.id
}

output "backend_subnet_id" {
  description = "The ID of the backend subnet"
  value       = aws_subnet.backend_subnet.id
}

output "database_subnet_id" {
  description = "The ID of the database subnet"
  value       = aws_subnet.database_subnet.id
}

# Internet Gateway Output
output "internet_gateway_id" {
  description = "The ID of the internet gateway"
  value       = aws_internet_gateway.main_gateway.id
}

# ECS Cluster Output
output "ecs_cluster_name" {
  description = "The name of the ECS Cluster"
  value       = aws_ecs_cluster.ecs_cluster.name
}

# ECR Repository URLs
output "backend_ecr_repository_url" {
  description = "The ECR repository URL for the backend"
  value       = aws_ecr_repository.backend_ecr_repo.repository_url
}

output "frontend_ecr_repository_url" {
  description = "The ECR repository URL for the frontend"
  value       = aws_ecr_repository.frontend_ecr_repo.repository_url
}

output "database_ecr_repository_url" {
  description = "The ECR repository URL for the database"
  value       = aws_ecr_repository.database_ecr_repo.repository_url
}

# ECS Service Outputs
output "backend_service_name" {
  description = "The name of the backend ECS service"
  value       = aws_ecs_service.backend_service.name
}

output "frontend_service_name" {
  description = "The name of the frontend ECS service"
  value       = aws_ecs_service.frontend_service.name
}

output "database_service_name" {
  description = "The name of the database ECS service"
  value       = aws_ecs_service.database_service.name
}

# Security Groups Outputs
output "frontend_security_group_id" {
  description = "The security group ID for the frontend"
  value       = aws_security_group.frontend_sg.id
}

output "backend_security_group_id" {
  description = "The security group ID for the backend"
  value       = aws_security_group.backend_sg.id
}

output "database_security_group_id" {
  description = "The security group ID for the database"
  value       = aws_security_group.database_sg.id
}

output "frontend_alb_url" {
  description = "The URL of the frontend application load balancer"
  value       = "http://${aws_lb.frontend_alb.dns_name}"
}

output "frontend_alb_dns_name" {
  description = "The DNS name of the frontend ALB"
  value       = aws_lb.frontend_alb.dns_name
}

output "frontend_alb_arn" {
  description = "The ARN of the frontend ALB"
  value       = aws_lb.frontend_alb.arn
}
