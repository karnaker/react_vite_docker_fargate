# Define variables to make the infrastructure configuration more flexible and reusable
variable "ami_id" {
  description = "The AMI ID of the EC2 instance"
}

variable "instance_type" {
  description = "The instance type of the EC2 instance"
}

variable "environment" {
  description = "The deployment environment (e.g., Development, Staging, Production)"
}

variable "project_name" {
  description = "The name of the project for resource tagging"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access"
}

# Configure the AWS provider with the specified region
provider "aws" {
  region = "us-east-1"
}

# Security Group to control access to the EC2 instance
resource "aws_security_group" "app_server_sg" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Allow limited traffic to app server"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tag the security group with metadata for identification and management
  tags = {
    Name        = "AppServerSG"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu   = "true"
  }
}

# Define an AWS EC2 instance resource with Security Group attached
resource "aws_instance" "app_server" {
  ami           = var.ami_id          # Use the AMI ID specified in the variable
  instance_type = var.instance_type   # Use the instance type specified in the variable

  vpc_security_group_ids = [aws_security_group.app_server_sg.id]

  # Configure the instance to use IMDSv2 for enhanced security
  metadata_options {
    # Enforce the use of IMDSv2 by setting the HTTP tokens to "required"
    http_tokens = "required"

    # Optionally, you can adjust the hop limit. The default is 1, which is typical for most use cases.
    http_put_response_hop_limit = 1

    # Setting the endpoint to "enabled" ensures that the IMDS is accessible.
    http_endpoint = "enabled"
  }

  # Tag the instance with metadata for identification and management
  tags = {
    Name        = "AppServer"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu   = "true"
  }
}
