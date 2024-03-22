# Create a new VPC for our project
resource "aws_vpc" "vite_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}_${var.environment}_vpc"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}

# Create an Internet Gateway for the VPC to allow communication with the internet
resource "aws_internet_gateway" "vite_igw" {
  vpc_id = aws_vpc.vite_vpc.id

  tags = {
    Name        = "${var.project_name}_${var.environment}_igw"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}
