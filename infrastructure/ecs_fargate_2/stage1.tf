##################################################
# provider.tf (for now in main.tf)
# Configure the AWS provider using the AWS region specified in the variables.
# This setup is essential for connecting OpenTofu with AWS services in the specified region.

provider "aws" {
  region = var.aws_region  # Fetch the region from the variable defined in variables.tf
}

##################################################
# variables.tf (for now in main.tf)
# Definition of variables used in the OpenTofu configuration.
# This file declares variables that configure aspects of AWS resources.

variable "aws_region" {
  description = "AWS region for the deployment."
  type        = string  # Ensuring type specificity for better error checking and clarity
}

variable "environment" {
  description = "The deployment environment (e.g., development, staging, production)."
  type        = string
}

variable "opentofu_enabled" {
  description = "Flag to indicate if the resource is managed under OpenTofu projects."
  type        = string  # Ensuring type specificity for better error checking and clarity.
}

variable "project_name" {
  description = "The name of the project for resource tagging."
  type        = string  # Define type to improve validation and error handling.
}

##################################################
# ecr_repository.tf (for now in main.tf)
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
