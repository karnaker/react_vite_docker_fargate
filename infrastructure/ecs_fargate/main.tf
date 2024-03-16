variable "aws_region" {
  description = "AWS region for the deployment."
}

variable "project_name" {
  description = "The name of the project for resource tagging."
}

variable "environment" {
  description = "The deployment environment (e.g., development, staging, production)."
}

# Configure the AWS provider with the specified region from variable
provider "aws" {
  region = var.aws_region
}

# ECR Repository Resource
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
    OpenTofu    = "true"
  }
}
