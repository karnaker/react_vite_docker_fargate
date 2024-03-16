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

# Function to delete Docker images from AWS ECR
delete_ecr_images() {
    # Fetch the list of image digests to delete
    # Note: Adjust the --query parameter as needed to target specific images
    IMAGE_DIGESTS=$(aws ecr list-images --repository-name ${PROJECT_NAME}_${ENVIRONMENT}_repository --region $AWS_REGION --query 'imageIds[*].imageDigest' --output text)

    if [ -z "$IMAGE_DIGESTS" ]; then
        echo "No images found in ${PROJECT_NAME}_${ENVIRONMENT}_repository."
        return
    fi

    # Confirmation before deletion
    echo "The following image digests will be deleted from ${PROJECT_NAME}_${ENVIRONMENT}_repository:"
    echo $IMAGE_DIGESTS
    read -p "Are you sure? (y/N): " -n 1 -r
    echo    # Move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
    fi

    # Delete images
    for DIGEST in $IMAGE_DIGESTS; do
        aws ecr batch-delete-image --repository-name ${PROJECT_NAME}_${ENVIRONMENT}_repository --region $AWS_REGION --image-ids imageDigest=$DIGEST
        if [ $? -eq 0 ]; then
            echo "Deleted image with digest: $DIGEST"
        else
            echo "Failed to delete image with digest: $DIGEST"
        fi
    done

    echo "Image deletion complete."
}

# Main script execution
set_env_vars
fetch_aws_credentials
get_aws_account_id
load_variables_from_tfvars
delete_ecr_images
