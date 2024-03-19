# ECR Repository Resource
resource "aws_ecr_repository" "do_react_vite_repository" {
  name = "${var.project_name}_${var.environment}_repository"
  
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  # Tags for identifying and organizing resources within AWS.
  tags = {
    Name        = "${var.project_name}_${var.environment}_repository"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}
