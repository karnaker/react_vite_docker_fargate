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
