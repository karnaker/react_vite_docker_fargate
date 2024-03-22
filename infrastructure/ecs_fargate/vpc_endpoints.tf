# ECR API Endpoint for private access to ECR
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = aws_vpc.vite_vpc.id
  service_name       = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.vite_subnet_private.*.id
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id] # Ensuring access from tasks to ECR API

  private_dns_enabled = true
  
  tags = {
    Name        = "${var.project_name}_${var.environment}_ecr_api_endpoint"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}

# ECR Docker Endpoint for private Docker login
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id             = aws_vpc.vite_vpc.id
  service_name       = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.vite_subnet_private.*.id
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id] # Ensuring tasks can pull Docker images

  private_dns_enabled = true
  
  tags = {
    Name        = "${var.project_name}_${var.environment}_ecr_dkr_endpoint"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}

# CloudWatch Logs Endpoint for ECS logging
resource "aws_vpc_endpoint" "cw_logs" {
  vpc_id             = aws_vpc.vite_vpc.id
  service_name       = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.vite_subnet_private.*.id
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id] # Ensuring tasks can send logs to CloudWatch

  private_dns_enabled = true
  
  tags = {
    Name        = "${var.project_name}_${var.environment}_cw_logs_endpoint"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}
