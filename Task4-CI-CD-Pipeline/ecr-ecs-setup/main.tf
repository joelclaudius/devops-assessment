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
  subnet_id     = aws_subnet.frontend_subnet.id  # Use public subnet
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




# VPC Endpoint for AWS Secrets Manager (Avoids Need for Internet)
resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id            = aws_vpc.main_vpc.id
  service_name      = "com.amazonaws.us-east-1.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.backend_subnet.id, aws_subnet.database_subnet.id]
  security_group_ids = [aws_security_group.backend_sg.id]

  private_dns_enabled = true
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
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "arn:aws:secretsmanager:us-east-1:670587392556:secret:my-app/db-credentials-*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
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
      "secrets": [
        {
          "name": "DB_HOST",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials"
        },
        {
          "name": "POSTGRES_USER",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials"
        },
        {
          "name": "POSTGRES_PASSWORD",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials"
        },
        {
          "name": "SECRET_KEY",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials"
        },
        {
          "name": "AWS_REGION",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials"
        },
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials"
        },
        {
          "name": "DJANGO_SETTINGS_MODULE",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials"
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
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials"
        },
        {
          "name": "POSTGRES_USER",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials"
        },
        {
          "name": "POSTGRES_PASSWORD",
          "valueFrom": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:my-app/db-credentials"
        }
      ]
    }
  ]
  EOF
}

# ECS Services
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
  security_groups   = [aws_security_group.frontend_sg.id]
  subnets            = [
    aws_subnet.frontend_subnet.id,  # Use the subnet in AZ1
    aws_subnet.frontend_subnet_b.id   # Use the subnet in AZ2
  ]

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  idle_timeout = 60  # Correct way to define idle timeout


  tags = {
    Name = "frontend-alb"
  }
}

# Create a target group for the frontend service
resource "aws_lb_target_group" "frontend_target_group" {
  name     = "frontend-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path = "/health"
    interval = 30
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
    type             = "fixed-response"
    fixed_response {
      status_code = 200
      content_type = "text/plain"
      message_body = "Welcome to the frontend!"
    }
  }
}

# Attach ECS frontend service to the ALB target group
resource "aws_lb_target_group_attachment" "frontend_service_attachment" {
  target_group_arn = aws_lb_target_group.frontend_target_group.arn
  target_id        = aws_ecs_service.frontend_service.id
  port             = 80
}
