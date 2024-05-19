##################################################
# ecs_fargate_service.tf (for now in main.tf)
# This section defines an AWS ECS service using Fargate as the launch type. 
# This service is responsible for managing the lifecycle of containers based on the defined task definition.

resource "aws_ecs_service" "do_react_vite_service" {
  name            = "${var.project_name}_${var.environment}_service"
  cluster         = aws_ecs_cluster.do_react_vite_cluster.id
  task_definition = aws_ecs_task_definition.do_react_vite_task.arn
  launch_type     = "FARGATE"
  
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
