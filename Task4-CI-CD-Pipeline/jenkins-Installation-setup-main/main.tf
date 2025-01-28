# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name
}

# ECR Repository for Backend
resource "aws_ecr_repository" "backend_ecr_repo" {
  name = "${var.ecr_backend_repo_name}"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "backend-ecr-repo"
  }
}

# ECR Repository for Database
resource "aws_ecr_repository" "database_ecr_repo" {
  name = "${var.ecr_database_repo_name}"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "database-ecr-repo"
  }
}

# ECR Repository for Frontend
resource "aws_ecr_repository" "frontend_ecr_repo" {
  name = "${var.ecr_frontend_repo_name}"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "frontend-ecr-repo"
  }
}



# ECR Lifecycle Policy for Backend
resource "aws_ecr_lifecycle_policy" "backend_ecr_policy" {
  repository = aws_ecr_repository.backend_ecr_repo.name

  policy = <<EOT
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Expire untagged images older than 30 days",
        "selection": {
          "tagStatus": "untagged",
          "countType": "imageCountMoreThan",
          "countNumber": 10
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOT
}

# ECR Lifecycle Policy for Database
resource "aws_ecr_lifecycle_policy" "database_ecr_policy" {
  repository = aws_ecr_repository.database_ecr_repo.name

  policy = <<EOT
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Expire untagged images older than 30 days",
        "selection": {
          "tagStatus": "untagged",
          "countType": "imageCountMoreThan",
          "countNumber": 10
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOT
}

# ECR Lifecycle Policy for Frontend
resource "aws_ecr_lifecycle_policy" "frontend_ecr_policy" {
  repository = aws_ecr_repository.frontend_ecr_repo.name

  policy = <<EOT
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Expire untagged images older than 30 days",
        "selection": {
          "tagStatus": "untagged",
          "countType": "imageCountMoreThan",
          "countNumber": 10
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOT
}
