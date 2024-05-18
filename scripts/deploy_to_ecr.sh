#!/bin/sh
# deploy_to_ecr.sh - Script to deploy Docker image to AWS ECR
# This script performs the following steps:
# - Set environment variables
# - Fetch AWS credentials
# - Get AWS account ID
# - Load variables from a specified Terraform variables file
# - Build, tag, and push Docker images to AWS ECR

# Define a function to source environmental variables
set_env_vars() {
    source ./scripts/set_env_vars.sh
}

# Define a function to fetch AWS credentials from the configured method
fetch_aws_credentials() {
    source ./scripts/fetch_aws_credentials.sh
}

# Define a function to retrieve the AWS account ID and ensure it's available for use in tags
get_aws_account_id() {
    source ./scripts/get_aws_account_id.sh
}

# Function to load variables from a user-specified tfvars file
# Accepts one argument: path to the tfvars file
load_variables_from_tfvars() {
    source ./scripts/load_tfvars.sh "$1"
}

# Function to build and tag the Docker image
# Utilizes environment variables loaded from the tfvars file
build_and_tag_image() {
    echo "Building Docker image for linux/arm64..."
    docker buildx build --platform linux/arm64 -t $PROJECT_NAME .

    echo "Tagging Docker image..."
    docker tag $PROJECT_NAME:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${PROJECT_NAME}_${ENVIRONMENT}_repository:latest
}

# Main deployment function that coordinates the authentication, building, tagging, and pushing of the Docker image
deploy_to_ecr() {
    echo "Authenticating Docker with AWS ECR..."
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

    build_and_tag_image

    echo "Pushing Docker image to AWS ECR..."
    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${PROJECT_NAME}_${ENVIRONMENT}_repository:latest

    echo "Docker image successfully pushed to AWS ECR."
}

# Script execution flow
# Validate user input for tfvars path
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_tfvars>"
    exit 1
fi

# Execute functions in the proper order
set_env_vars
fetch_aws_credentials
get_aws_account_id
load_variables_from_tfvars "$1"
deploy_to_ecr
