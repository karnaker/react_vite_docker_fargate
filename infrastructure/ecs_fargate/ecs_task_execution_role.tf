# Resource: AWS IAM Role for ECS Task Execution
# This IAM role is specifically created for Amazon ECS tasks. It allows ECS tasks to call AWS services on your behalf.
resource "aws_iam_role" "ecs_task_execution_role" {
  # Name of the IAM role.
  name = "ecs_task_execution_role"

  # Policy that grants an entity permission to assume the role.
  # Here, it allows the ECS tasks service to assume this role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17", # IAM policies version.
    Statement = [
      {
        Action = "sts:AssumeRole", # The action that allows entities to assume the role.
        Effect = "Allow",          # This policy statement allows the action.
        Principal = {
          Service = "ecs-tasks.amazonaws.com" # The ECS tasks service is allowed to assume this role.
        }
      },
    ]
  })

  # Tags for identifying and organizing resources within AWS.
  tags = {
    Name        = "${var.project_name}_${var.environment}_iam_role_ecs_task_execution"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}

# Resource: Attach the Amazon ECS Task Execution Role Policy to the IAM Role
# This attachment grants the ECS Task Execution Role the necessary permissions defined in the AWS managed policy.
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  # The role to attach the policy to.
  role = aws_iam_role.ecs_task_execution_role.name
  
  # The ARN of the AWS managed policy for ECS Task Execution. This policy provides the permissions necessary for the ECS agent and Docker daemon to pull images, store logs, and so on.
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
