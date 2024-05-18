#!/bin/sh

# Source environment variables and fetch AWS credentials
DIR="$(dirname "$0")" # Get the directory where the script is located
source "$DIR/set_env_vars.sh"
source "$DIR/fetch_aws_credentials.sh"

# This will be set based on script arguments
INFRASTRUCTURE_DIR=""

# Function to change to the specified infrastructure directory and run OpenTofu command
run_opentofu_command_in_infrastructure() {
    if [[ -z $AWS_ACCESS_KEY_ID ]] || [[ -z $AWS_SECRET_ACCESS_KEY ]]; then
        echo "AWS credentials not found. Aborting..."
        exit 1
    fi

    # Change to the specified infrastructure subdirectory
    echo "Changing to infrastructure subdirectory: $INFRASTRUCTURE_DIR"
    cd "$INFRASTRUCTURE_DIR" || exit

    echo "Running OpenTofu command in $(pwd): $*"
    "$@"
}

# Main function to orchestrate the script's flow
main() {
    # Check for correct usage
    if [ "$#" -lt 2 ]; then
        echo "Usage: $0 <infrastructure_subdir> <opentofu_command> [args...]"
        exit 1
    fi

    # First argument is the subdirectory under infrastructure
    INFRASTRUCTURE_DIR="./infrastructure/$1"
    shift  # Remove the first argument so "$@" now contains the OpenTofu command and its arguments

    # Execute the command in the specified infrastructure directory
    run_opentofu_command_in_infrastructure "$@"
}

# Execute the main function with all passed arguments
main "$@"
