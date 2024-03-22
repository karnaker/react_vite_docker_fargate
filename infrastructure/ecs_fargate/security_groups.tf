# Security group for the Application Load Balancer
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.vite_vpc.id
  name        = "${var.project_name}_${var.environment}_alb_sg"
  description = "ALB security group for ${var.project_name} in ${var.environment}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow all inbound HTTP traffic
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name        = "${var.project_name}_${var.environment}_alb_sg"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}

# Security group for ECS Fargate tasks
resource "aws_security_group" "ecs_tasks_sg" {
  vpc_id = aws_vpc.vite_vpc.id
  name        = "${var.project_name}_${var.environment}_ecs_tasks_sg"
  description = "ECS tasks security group for ${var.project_name} in ${var.environment}"

  # Allow inbound traffic from ALB to the ECS tasks
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow all outbound traffic from ECS tasks (for pulling images, sending logs, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}_${var.environment}_ecs_tasks_sg"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}

# Security group for VPC Endpoints for secure, private access to AWS Services
resource "aws_security_group" "vpc_endpoints_sg" {
  vpc_id = aws_vpc.vite_vpc.id
  name        = "${var.project_name}_${var.environment}_vpc_endpoints_sg"
  description = "VPC endpoints security group for ${var.project_name} in ${var.environment}"

  # Allow inbound traffic from ECS tasks to VPC Endpoints
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks_sg.id]
  }

  tags = {
    Name        = "${var.project_name}_${var.environment}_vpc_endpoints_sg"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}
