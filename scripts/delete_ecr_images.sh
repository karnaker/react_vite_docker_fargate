#!/bin/sh
# delete_ecr_images.sh - Script to delete Docker images from AWS ECR
# This script performs steps to set environment variables, fetch AWS credentials,
# retrieve the AWS account ID, load specific configuration from Terraform variables files,
# and delete Docker images based on user confirmation.

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

# Function to load variables from a user-specified tfvars file
# Accepts one argument: path to the tfvars file
load_variables_from_tfvars() {
    if [[ -f "$1" ]]; then
        source ./scripts/load_tfvars.sh "$1"
    else
        echo "Error: Specified tfvars file does not exist."
        exit 1
    fi
}

# Function to delete Docker images from AWS ECR
delete_ecr_images() {
     echo "Fetching list of image digests from ${PROJECT_NAME}_${ENVIRONMENT}_repository..."
    IMAGE_DIGESTS=$(aws ecr list-images --repository-name ${PROJECT_NAME}_${ENVIRONMENT}_repository --region $AWS_REGION --query 'imageIds[*].imageDigest' --output text)

    if [ -z "$IMAGE_DIGESTS" ]; then
        echo "No images found in ${PROJECT_NAME}_${ENVIRONMENT}_repository."
        return
    fi

    echo "The following image digests will be deleted from ${PROJECT_NAME}_${ENVIRONMENT}_repository:"
    echo $IMAGE_DIGESTS
    read -p "Are you sure you want to delete these images? (y/N): " -n 1 -r
    echo    # Move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Image deletion aborted by user."
        exit 1
    fi

    # Deleting images
    for DIGEST in $IMAGE_DIGESTS; do
        echo "Deleting image with digest: $DIGEST"
        aws ecr batch-delete-image --repository-name ${PROJECT_NAME}_${ENVIRONMENT}_repository --region $AWS_REGION --image-ids imageDigest=$DIGEST
        if [ $? -eq 0 ]; then
            echo "Successfully deleted image with digest: $DIGEST"
        else
            echo "Failed to delete image with digest: $DIGEST"
        fi
    done

    echo "Image deletion process completed."
}

# Main script execution
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_tfvars>"
    exit 1
fi

set_env_vars
fetch_aws_credentials
get_aws_account_id
load_variables_from_tfvars "$1"
delete_ecr_images
