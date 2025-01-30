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

resource "aws_subnet" "frontend_subnet_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"  # Specify the second AZ
  map_public_ip_on_launch = true
  tags = {
    Name = "frontend-subnet-b"
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
  subnet_id     = aws_subnet.frontend_subnet.id  # Ensure this is a public subnet
}






# Create Internet Gateway
resource "aws_internet_gateway" "main_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-gateway"
  }
}

# Create Route Table and Associate with Subnets


# Public Route Table (Frontend)
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gateway.id
  }
}



# Associate Public Route Table with Frontend Subnet
resource "aws_route_table_association" "frontend_association" {
  subnet_id      = aws_subnet.frontend_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}


resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "private-route-table"
  }
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


resource "aws_security_group_rule" "secrets_manager_sg_rule" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  security_group_id = aws_security_group.backend_sg.id
  cidr_blocks = ["10.0.0.0/16"]  # Ensure this matches your VPC range
}



resource "aws_security_group" "frontend_sg" {
  name        = "frontend-sg"
  description = "Frontend security group"
  vpc_id      = aws_vpc.main_vpc.id

  # Allow incoming traffic on port 80 (HTTP)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world (modify as needed)
  }

  # Allow incoming traffic on port 443 (HTTPS)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world (modify as needed)
  }

  # Allow outbound internet access for ECR & other services
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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




# VPC Endpoint for AWS Secrets Manager (Avoids Need for Internet)
resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id            = aws_vpc.main_vpc.id
  service_name      = "com.amazonaws.us-east-1.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.backend_subnet.id, aws_subnet.database_subnet.id]
  security_group_ids = [aws_security_group.backend_sg.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id       = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids   = [aws_subnet.backend_subnet.id, aws_subnet.database_subnet.id]
  security_group_ids = [aws_security_group.backend_sg.id]
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id       = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids   = [aws_subnet.backend_subnet.id, aws_subnet.database_subnet.id]
  security_group_ids = [aws_security_group.backend_sg.id]
}


# ECS Execution Role
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Policy for ECS Execution Role
resource "aws_iam_policy" "ecs_execution_role_policy" {
  name        = "ecs-execution-role-policy"
  description = "Allows ECS to retrieve images from ECR and fetch secrets from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken"  # 🔥 Add this line to fix auth error
        ],
        Resource = "*"
      },

      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/ecs/*"
      },

      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "arn:aws:secretsmanager:us-east-1:670587392556:secret:my-app/db-credentials-*"
      },
      {
        Effect = "Allow",
        Action = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the ECS execution role
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_attach" {
  policy_arn = aws_iam_policy.ecs_execution_role_policy.arn
  role       = aws_iam_role.ecs_execution_role.name
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
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.ecs_log_group.name}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "backend"
        }
      },
      "secrets": [
        {
          "name": "DB_HOST",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials::DB_HOST::"
        },
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials:DATABASE_URL::"
        },
        {
          "name": "DJANGO_SETTINGS_MODULE",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials:DJANGO_SETTINGS_MODULE::"
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
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = <<EOF
  [
    {
      "name": "frontend",
      "image": "${aws_ecr_repository.frontend_ecr_repo.repository_url}:latest",
      "memory": 512,
      "cpu": 256,
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.ecs_log_group.name}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "frontend"
        }
      },

      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ],
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3
      }
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
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "database"
      image     = "${aws_ecr_repository.database_ecr_repo.repository_url}:latest"
      memory    = 512
      cpu       = 256
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.ecs_log_group.name}"
          awslogs-region        = "${var.aws_region}"
          awslogs-stream-prefix = "database"
        }
      }
      secrets = [
        {
          name      = "POSTGRES_DB"
          valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials:POSTGRES_DB::"
        },
        {
          name      = "POSTGRES_USER"
          valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials:POSTGRES_USER::"
        },
        {
          name      = "POSTGRES_PASSWORD"
          valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials:POSTGRES_PASSWORD::"
        }
      ]
    }
  ])
}


# Create a private DNS namespace for service discovery
resource "aws_service_discovery_private_dns_namespace" "my_namespace" {
  name = "my-namespace.local"  # Change this if needed
  vpc  = aws_vpc.main_vpc.id
}



resource "aws_service_discovery_service" "backend_service_discovery" {
  name = "backend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.my_namespace.id

    dns_records {
      type = "A"
      ttl  = 10
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}


# ECS Services
resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
  subnets          = [aws_subnet.frontend_subnet.id]
  security_groups  = [aws_security_group.frontend_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
    container_name   = "frontend"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.frontend_listener]  # Ensure listener is created first
}





# ECS Service (Backend)
resource "aws_ecs_service" "backend_service" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.backend_subnet.id]
    security_groups  = [aws_security_group.backend_sg.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.backend_service_discovery.arn
  }

}

# ECS Service (Database)
resource "aws_ecs_service" "database_service" {
  name            = "database-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.database_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.database_subnet.id]
    security_groups  = [aws_security_group.database_sg.id]
    assign_public_ip = false
  }
}


# Create Application Load Balancer
resource "aws_lb" "frontend_alb" {
  name               = "frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.frontend_sg.id]
  subnets            = [
    aws_subnet.frontend_subnet.id,
    aws_subnet.frontend_subnet_b.id
  ]

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  idle_timeout = 60

  tags = {
    Name = "frontend-alb"
  }
}


# Create a target group for the frontend service
resource "aws_lb_target_group" "frontend_target_group" {
  name        = "frontend-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main_vpc.id
  target_type = "ip"  # Ensure compatibility with ECS Fargate (awsvpc mode)

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "frontend-target-group"
  }
}


# Listener for the ALB
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
  }
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/ecs-app-logs"
  retention_in_days = 7  # Adjust the retention period as needed
}


