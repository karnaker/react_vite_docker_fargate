#!/bin/sh
# delete_local_docker_images.sh - Script to delete local Docker images

# Function to load variables from a user-specified tfvars file
load_variables() {
    local tfvars_path="$1"
    if [ -f "$tfvars_path" ]; then
        source ./scripts/load_tfvars.sh "$tfvars_path"
    else
        echo "Error: Specified tfvars file '$tfvars_path' does not exist."
        exit 1
    fi
}

# Function to delete Docker images related to the project
delete_project_images() {
    echo "Fetching Docker images for the project: $PROJECT_NAME..."
    local project_images=$(docker images "$PROJECT_NAME" -q)

    if [ -z "$project_images" ]; then
        echo "No Docker images found for the project: $PROJECT_NAME."
    else
        echo "Deleting Docker images for the project: $PROJECT_NAME..."
        for image_id in $project_images; do
            docker rmi -f "$image_id" && echo "Deleted image with ID: $image_id" || echo "Failed to delete image with ID: $image_id"
        done
        echo "Docker images deletion attempt completed."
    fi
}

# Main function to orchestrate the script execution
main() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 <path_to_tfvars>"
        exit 1
    fi

    echo "Starting to delete local Docker images..."
    load_variables "$1"
    delete_project_images
    echo "Deletion process completed."
}

# Execute main function with all passed arguments
main "$@"
