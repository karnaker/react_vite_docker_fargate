# Local variables for sanitized naming conventions
locals {
  # Sanitize project_name by replacing underscores with hyphens to comply with AWS load balancer naming conventions.
  # AWS load balancer resource names cannot contain underscores, so we ensure that our naming pattern is consistent
  # and avoids deployment errors by using only allowed characters (alphanumeric and hyphens).
  project_name_sanitized = replace(var.project_name, "_", "-")

  # Apply the same sanitization process to the environment variable for the same reasons
  # outlined above. This ensures that all load balancer resources related to a specific environment
  # follow the AWS load balancer naming conventions without causing errors during deployment.
  environment_sanitized  = replace(var.environment, "_", "-")
}

# Define the Application Load Balancer for the project
resource "aws_lb" "vite_alb" {
  name               = "${local.project_name_sanitized}-${local.environment_sanitized}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.vite_subnet_public.*.id

  tags = {
    Name        = "${local.project_name_sanitized}-${local.environment_sanitized}-alb"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}

# Define a target group for directing requests to the appropriate containers
resource "aws_lb_target_group" "vite_tg" {
  name     = "${local.project_name_sanitized}-${local.environment_sanitized}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vite_vpc.id
  target_type = "ip" # Specify target type as IP to be compatible with awsvpc network mode

  health_check {
    protocol            = "HTTP"
    path                = "/" # Adjust if your app has a specific health check endpoint
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name        = "${local.project_name_sanitized}-${local.environment_sanitized}-tg"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}

# Create a listener for the ALB to forward requests to the target group
resource "aws_lb_listener" "vite_listener" {
  load_balancer_arn = aws_lb.vite_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vite_tg.arn
  }

  tags = {
    Name        = "${local.project_name_sanitized}-${local.environment_sanitized}-listener"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}
