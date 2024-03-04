# Configure the AWS provider with the specified region
provider "aws" {
  region = "us-east-1"
}

# Define an AWS EC2 instance resource
resource "aws_instance" "app_server" {
  ami           = "ami-07d9b9ddc6cd8dd30" # Use the AMI ID specified in the variable
  instance_type = "t2.nano"               # Use the instance type specified in the variable

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
    Environment = "Development"
    Project     = "do_react_vite"
  }
}
