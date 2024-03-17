#!/bin/bash

# Load variables from the tfvars file
source ./scripts/load_tfvars.sh
load_variables_from_tfvars "./infrastructure/ecs_fargate/ecs_fargate_dev.tfvars"

# Function to delete Docker images related to the project
delete_project_images() {
    # Fetch all images tagged with the project name and remove them
    PROJECT_IMAGES=$(docker images "$PROJECT_NAME" -q)

    if [ -z "$PROJECT_IMAGES" ]; then
        echo "No Docker images found for the project: $PROJECT_NAME"
    else
        echo "Deleting Docker images for the project: $PROJECT_NAME"
        for image_id in $PROJECT_IMAGES; do
            docker rmi -f "$image_id" || echo "Failed to delete image with ID $image_id"
        done
        echo "Docker images deletion attempt completed."
    fi
}

# Main function
main() {
    echo "Starting to delete local Docker images created by deploy_to_ecr.sh..."
    delete_project_images
    echo "Deletion attempt process completed."
}

# Execute main function
main
