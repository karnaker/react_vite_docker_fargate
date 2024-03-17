#!/bin/bash

# Define function to set environment variables
set_env_vars() {
    source ./scripts/set_env_vars.sh
}

# Define function to fetch AWS credentials
fetch_aws_credentials() {
    source ./scripts/fetch_aws_credentials.sh
}

# Define function to get AWS account ID
get_aws_account_id() {
    source ./scripts/get_aws_account_id.sh
}

# Define function to load variables from tfvars file
load_variables_from_tfvars() {
    source ./scripts/load_tfvars.sh
    load_variables_from_tfvars "./infrastructure/ecs_fargate/ecs_fargate_dev.tfvars"
}

# Define a function to build and tag the Docker image
build_and_tag_image() {
    echo "Building Docker image for linux/arm64..."
    docker buildx build --platform linux/arm64 -t $PROJECT_NAME .

    echo "Tagging Docker image..."
    docker tag $PROJECT_NAME:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${PROJECT_NAME}_${ENVIRONMENT}_repository:latest
}

# Define main deployment function
deploy_to_ecr() {
    # Authenticate Docker to AWS ECR
    echo "Authenticating Docker with AWS ECR..."
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

    # Build and tag Docker image for arm64
    build_and_tag_image

    # Push Docker image to ECR
    echo "Pushing Docker image to AWS ECR..."
    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${PROJECT_NAME}_${ENVIRONMENT}_repository:latest

    echo "Docker image successfully pushed to AWS ECR."
}

# Execute functions
set_env_vars
fetch_aws_credentials
get_aws_account_id
load_variables_from_tfvars
deploy_to_ecr
