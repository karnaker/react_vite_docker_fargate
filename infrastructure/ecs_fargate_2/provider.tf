# Configure the AWS provider using the AWS region specified in the variables.
# This setup is essential for connecting OpenTofu with AWS services in the specified region.

provider "aws" {
  region = var.aws_region  # Fetch the region from the variable defined in variables.tf
}
