provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-07d9b9ddc6cd8dd30"
  instance_type = "t2.nano"

  metadata_options {
    // Enforce the use of IMDSv2 by setting the HTTP tokens to "required"
    http_tokens = "required"

    // Optionally, you can adjust the hop limit. The default is 1, which is typical for most use cases.
    http_put_response_hop_limit = 1

    // Setting the endpoint to "enabled" ensures that the IMDS is accessible.
    http_endpoint = "enabled"
  }

  tags = {
    Name        = "AppServer"
    Environment = "Development"
    Project     = "do_react_vite"
  }
}
