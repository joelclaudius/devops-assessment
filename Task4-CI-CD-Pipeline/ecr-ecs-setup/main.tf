resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name
}

resource "aws_ecr_repository" "backend_ecr_repo" {
  name = var.ecr_backend_repo_name

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "backend-ecr-repo"
  }
}

resource "aws_ecr_repository" "database_ecr_repo" {
  name = var.ecr_database_repo_name

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "database-ecr-repo"
  }
}

resource "aws_ecr_repository" "frontend_ecr_repo" {
  name = var.ecr_frontend_repo_name

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "frontend-ecr-repo"
  }
}

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


resource "aws_ecs_task_definition" "backend_task" {
  family                   = "backend-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  container_definitions = <<EOF
  [
    {
      "name": "backend",
      "image": "${aws_ecr_repository.backend_ecr_repo.repository_url}:${var.backend_image_tag}",
      "memory": 512,
      "cpu": 256,
      "essential": true,
      "secrets": [
        {
          "name": "DB_HOST",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials-DB_HOST"
        },
        {
          "name": "DB_USER",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials-POSTGRES_USER"
        },
        {
          "name": "DB_PASSWORD",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials-POSTGRES_PASSWORD"
        },
        {
          "name": "SECRET_KEY",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials-SECRET_KEY"
        },
        {
          "name": "AWS_REGION",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials-AWS_REGION"
        },
         {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials-DATABASE_URL"
        },
         {
          "name": "DJANGO_SETTINGS_MODULE",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials-DJANGO_SETTINGS_MODULE"
        }
      ]
    }
  ]
  EOF
}

resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "frontend-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  container_definitions = <<EOF
  [
    {
      "name": "frontend",
      "image": "${aws_ecr_repository.frontend_ecr_repo.repository_url}:${var.frontend_image_tag}",
      "memory": 512,
      "cpu": 256,
      "essential": true,
    }
  ]
  EOF
}

resource "aws_ecs_task_definition" "database_task" {
  family                   = "database-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  container_definitions = <<EOF
  [
    {
      "name": "database",
      "image": "${aws_ecr_repository.database_ecr_repo.repository_url}:${var.database_image_tag}",
      "memory": 512,
      "cpu": 256,
      "essential": true,
      "secrets": [
        {
          "name": "POSTGRES_DB",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials-POSTGRES_DB"
        },
        {
          "name": "POSTGRES_USER",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials-POSTGRES_USER"
        },
        {
          "name": "POSTGRES_PASSWORD",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials-POSTGRES_PASSWORD"
        }
      ]
    }
  ]
  EOF
}


resource "aws_ecs_service" "backend_service" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups = var.security_group_ids
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups = var.security_group_ids
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "database_service" {
  name            = "database-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.database_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups = var.security_group_ids
    assign_public_ip = true
  }
}


