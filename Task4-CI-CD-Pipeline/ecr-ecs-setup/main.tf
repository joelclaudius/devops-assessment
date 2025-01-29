# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# Create Subnets
resource "aws_subnet" "frontend_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "frontend-subnet"
  }
}

resource "aws_subnet" "backend_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false  # Private subnet
  tags = {
    Name = "backend-subnet"
  }
}

resource "aws_subnet" "database_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false  # Private subnet
  tags = {
    Name = "database-subnet"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.frontend_subnet.id  # Use public subnet
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}



# Create Internet Gateway
resource "aws_internet_gateway" "main_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-gateway"
  }
}

# Create Route Table and Associate with Subnets
resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gateway.id
  }

  tags = {
    Name = "main-route-table"
  }
}

resource "aws_route_table_association" "frontend_association" {
  subnet_id      = aws_subnet.frontend_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_route_table_association" "backend_private_association" {
  subnet_id      = aws_subnet.backend_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "database_private_association" {
  subnet_id      = aws_subnet.database_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}


# Create Security Groups


resource "aws_security_group" "backend_sg" {
  name        = "backend-sg"
  description = "Backend security group"
  vpc_id      = aws_vpc.main_vpc.id

  # Allow outbound internet access for ECR
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "frontend_sg" {
  name        = "frontend-sg"
  description = "Frontend security group"
  vpc_id      = aws_vpc.main_vpc.id

  # Allow outbound internet access for ECR
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "database_sg" {
  name        = "database-sg"
  description = "database security group"
  vpc_id      = aws_vpc.main_vpc.id

  # Allow outbound internet access for ECR
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name
}

# ECR Repositories
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

# ECR Lifecycle Policies
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

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect    = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_execution_policy_attachment" {
  name       = "ecs_execution_policy_attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  roles      = [aws_iam_role.ecs_execution_role.name]
}



# ECS Task Definitions
resource "aws_ecs_task_definition" "backend_task" {
  family                   = "backend-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn  # Add this line


  container_definitions = <<EOF
  [
    {
      "name": "backend",
      "image": "${aws_ecr_repository.backend_ecr_repo.repository_url}:latest",
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
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn  # Add this line


  container_definitions = <<EOF
  [
    {
      "name": "frontend",
      "image": "${aws_ecr_repository.frontend_ecr_repo.repository_url}:latest",
      "memory": 512,
      "cpu": 256,
      "essential": true
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
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn  # Add this line


  container_definitions = <<EOF
  [
    {
      "name": "database",
      "image": "${aws_ecr_repository.database_ecr_repo.repository_url}:latest",
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

# ECS Services
resource "aws_ecs_service" "backend_service" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.backend_subnet.id]  # Private subnet
    security_groups  = [aws_security_group.backend_sg.id]
    assign_public_ip = false  # No public IP, uses NAT
  }
}

resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.frontend_subnet.id]  # Public subnet
    security_groups  = [aws_security_group.frontend_sg.id]
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
    subnets          = [aws_subnet.database_subnet.id]  # Private subnet
    security_groups  = [aws_security_group.database_sg.id]
    assign_public_ip = false  # No public IP, uses NAT
  }
}

