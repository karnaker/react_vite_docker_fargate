variable "aws_region" {
  description = "AWS region for the deployment."
}

variable "project_name" {
  description = "The name of the project for resource tagging."
}

variable "environment" {
  description = "The deployment environment (e.g., development, staging, production)."
}

variable "availability_zones" {
  description = "List of availability zones in the region for high availability"
  type        = list(string)
}
