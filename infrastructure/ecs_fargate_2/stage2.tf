##################################################
# ecs_fargate_service.tf (for now in main.tf)
# This section defines an AWS ECS service using Fargate as the launch type. 
# This service is responsible for managing the lifecycle of containers based on the defined task definition.

resource "aws_ecs_service" "do_react_vite_service" {
  name            = "${var.project_name}_${var.environment}_service"
  cluster         = aws_ecs_cluster.do_react_vite_cluster.id
  task_definition = aws_ecs_task_definition.do_react_vite_task.arn
  launch_type     = "FARGATE"
  desired_count    = 1  # Define how many instances of the task should run

  network_configuration {
    assign_public_ip = false

    security_groups  = [
      aws_security_group.egress_all.id,
      aws_security_group.ingress_api.id
    ]

    subnets          = [
      aws_subnet.private_subnet_1.id,
      aws_subnet.private_subnet_2.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.do_react_vite_target_group.arn
    container_name   = var.project_name
    container_port   = 3000
  }
  
  # Tags for resource identification and management in AWS
  tags = {
    Name        = "${var.project_name}_${var.environment}_service"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = var.opentofu_enabled
  }
}

##################################################
# cloudwatch_log_group.tf (for now in main.tf)
# CloudWatch Log Group for storing logs from ECS tasks
resource "aws_cloudwatch_log_group" "do_react_vite_log_group" {
  name = "/ecs/${var.project_name}/${var.environment}"
  
  retention_in_days = 30  # Defines how long logs are kept; adjust as needed

  tags = {
    Name        = "${var.project_name}_${var.environment}_log_group"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = var.opentofu_enabled
  }
}

##################################################
# ecs_task_definition.tf (for now in main.tf)
# ECS Task Definition for the Fargate service
resource "aws_ecs_task_definition" "do_react_vite_task" {
  family                   = "${var.project_name}_${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"  # Minimum vCPU for Fargate
  memory                   = "512"  # Minimum memory in MiB for Fargate
  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  # Assign the IAM role for task execution
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  
  container_definitions = jsonencode([
    {
      name      = "${var.project_name}"
      image     = "${aws_ecr_repository.do_react_vite_repository.repository_url}:latest"
      essential = true
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.do_react_vite_log_group.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.project_name}_${var.environment}_task"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = var.opentofu_enabled
  }
}

##################################################
# ecs_task_execution_role.tf (for now in main.tf)
# IAM role that ECS tasks will assume
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project_name}-${var.environment}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-task-role"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = var.opentofu_enabled
  }
}

# ecs_task_assume_role_policy.tf (for now in main.tf)
# IAM policy document that defines the trust relationship for ECS tasks
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ecs_task_execution_role_policy.tf
# Reference to AWS managed policy for ECS task execution
data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Attachment of the AWS managed execution role policy to the IAM role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role_policy.arn
}

##################################################
# ecs_cluster.tf (for now in main.tf)
# This section creates an AWS ECS Cluster which will host our Fargate services

resource "aws_ecs_cluster" "do_react_vite_cluster" {
  name = "${var.project_name}_${var.environment}_cluster"

  tags = {
    Name        = "${var.project_name}_${var.environment}_cluster"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = var.opentofu_enabled
  }
}

##################################################
# alb.tf (for now in main.tf)
# Application Load Balancer (ALB) for distributing traffic to the Fargate service

resource "aws_lb_target_group" "do_react_vite_target_group" {
  name        = "${var.project_name}-${var.environment}-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.do_react_vite_vpc.id

  health_check {
    enabled = true
    path    = "/health"
  }

  depends_on = [aws_alb.do_react_vite_alb]

  tags = {
    Name        = "${var.project_name}-${var.environment}-tg"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = var.opentofu_enabled
  }
}

resource "aws_alb" "do_react_vite_alb" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id,
  ]

  security_groups = [
    aws_security_group.http.id,
    aws_security_group.https.id,
    aws_security_group.egress_all.id,
  ]

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = var.opentofu_enabled
  }
}

resource "aws_alb_listener" "do_react_vite_http_listener" {
  load_balancer_arn = aws_alb.do_react_vite_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.do_react_vite_target_group.arn
  }
}

output "alb_url" {
  description = "URL of the Application Load Balancer"
  value       = "http://${aws_alb.do_react_vite_alb.dns_name}"
}

##################################################
# network.tf (for now in main.tf)
# VPC and networking resources for the Fargate service

# Create a VPC
# Define a VPC (Virtual Private Cloud) that provides a logically isolated
# section of the AWS Cloud where you can launch AWS resources.
resource "aws_vpc" "do_react_vite_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = "${var.project_name}_${var.environment}_vpc"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = var.opentofu_enabled
  }
}

# Define Subnets
# Define both public and private subnets across at least two 
# Availability Zones (AZs) to ensure high availability and fault tolerance.
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.do_react_vite_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.project_name}_${var.environment}_public_subnet_1"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = var.opentofu_enabled
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.do_react_vite_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.project_name}_${var.environment}_private_subnet_1"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = var.opentofu_enabled
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.do_react_vite_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "${var.project_name}_${var.environment}_public_subnet_2"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = var.opentofu_enabled
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.do_react_vite_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "${var.project_name}_${var.environment}_private_subnet_2"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = var.opentofu_enabled
  }
}

# Route Tables
# Define routing for public and private subnets, associating each with the
# correct resources.
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.do_react_vite_vpc.id

  tags = {
    Name = "${var.project_name}_${var.environment}_public_route_table"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = var.opentofu_enabled
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.do_react_vite_vpc.id

  tags = {
    Name = "${var.project_name}_${var.environment}_private_route_table"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = var.opentofu_enabled
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Internet Gateway and NAT Gateway
# Public subnets need an internet gateway to communicate with the internet, and
# private subnets use a NAT gateway for outbound traffic.
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.do_react_vite_vpc.id

  tags = {
    Name = "${var.project_name}_${var.environment}_igw"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = var.opentofu_enabled
  }
}

resource "aws_nat_gateway" "ngw" {
  subnet_id     = aws_subnet.public_subnet_1.id
  allocation_id = aws_eip.nat_eip.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.project_name}_${var.environment}_ngw"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = var.opentofu_enabled
  }
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_ngw" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

# Security Groups
# Define security groups for various levels of access control.
resource "aws_security_group" "http" {
  name        = "http"
  description = "HTTP traffic"
  vpc_id      = aws_vpc.do_react_vite_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "https" {
  name        = "https"
  description = "HTTPS traffic"
  vpc_id      = aws_vpc.do_react_vite_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "egress_all" {
  name        = "egress-all"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.do_react_vite_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress_api" {
  name        = "ingress-api"
  description = "Allow ingress to API"
  vpc_id      = aws_vpc.do_react_vite_vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

