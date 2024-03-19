resource "aws_ecs_task_definition" "vite_task" {
  family                   = "do_react_vite_task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  # The container definition section defines the settings for the Docker container that is launched as part of this task.
  container_definitions = jsonencode([
    {
      name         = "do_react_vite"
      image        = "${aws_ecr_repository.do_react_vite_repository.repository_url}:latest" # Ensure this image is available in ECR.
      essential    = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      # Include other container settings here as required.
    }
  ])
  
  # Tags for identifying and organizing resources within AWS.
  tags = {
    Name = "${var.project_name}_${var.environment}_task_definition"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}
