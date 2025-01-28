# print the url of the jenkins server
output "jenkins_url" {
  value     = join ("", ["http://", aws_instance.ec2_instance.public_dns, ":", "8080"])
}

# print the url of the jenkins server
output "ssh_connection_command" {
  value     = join ("", ["ssh -i jenkins_key_pair.pem ec2-user@", aws_instance.ec2_instance.public_dns])
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.ecs_cluster.name
}

output "backend_ecr_repository_url" {
  description = "URL of the ECR repository for the backend service"
  value       = aws_ecr_repository.backend_ecr_repo.repository_url
}

output "frontend_ecr_repository_url" {
  description = "URL of the ECR repository for the frontend service"
  value       = aws_ecr_repository.frontend_ecr_repo.repository_url
}

output "database_ecr_repository_url" {
  description = "URL of the ECR repository for the database service"
  value       = aws_ecr_repository.database_ecr_repo.repository_url
}

output "backend_ecr_lifecycle_policy" {
  description = "Lifecycle policy for the backend ECR repository"
  value       = aws_ecr_lifecycle_policy.backend_ecr_policy.policy
}

output "frontend_ecr_lifecycle_policy" {
  description = "Lifecycle policy for the frontend ECR repository"
  value       = aws_ecr_lifecycle_policy.frontend_ecr_policy.policy
}

output "database_ecr_lifecycle_policy" {
  description = "Lifecycle policy for the database ECR repository"
  value       = aws_ecr_lifecycle_policy.database_ecr_policy.policy
}
