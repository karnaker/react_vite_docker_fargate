# This file creates an AWS Elastic Container Registry (ECR) repository to store Docker images.
# The repository's properties are configured to support mutable image tags and automatic scanning on push.

resource "aws_ecr_repository" "do_react_vite_repository" {
  name = "${var.project_name}_${var.environment}_repository"
  
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}_${var.environment}_repository"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = var.opentofu_enabled
  }
}
