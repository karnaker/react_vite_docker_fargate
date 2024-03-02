#!/bin/bash

# Source environment variables from set_env_vars.sh
DIR="$(dirname "$0")"  # Get the directory where the script is located
source "$DIR/set_env_vars.sh"

# Define the directory where your OpenTofu configuration (.tf files) is located
INFRASTRUCTURE_DIR="./infrastructure"

#!/bin/bash

# Function to fetch AWS credentials from 1Password using environment variables
fetch_aws_credentials() {
    if [[ -z "${OP_AWS_ACCOUNT_ID}" ]] || [[ -z "${OP_AWS_ACCESS_KEY_FIELD}" ]] || [[ -z "${OP_AWS_SECRET_KEY_FIELD}" ]]; then
        echo "Environment variables OP_AWS_ACCOUNT_ID, OP_AWS_ACCESS_KEY_FIELD, and OP_AWS_SECRET_KEY_FIELD must be set."
        exit 1
    fi

    echo "Fetching AWS credentials for ${OP_AWS_ACCOUNT_ID} from 1Password..."
    export AWS_ACCESS_KEY_ID=$(op item get "${OP_AWS_ACCOUNT_ID}" --fields "${OP_AWS_ACCESS_KEY_FIELD}")
    export AWS_SECRET_ACCESS_KEY=$(op item get "${OP_AWS_ACCOUNT_ID}" --fields "${OP_AWS_SECRET_KEY_FIELD}")
    
    # Optionally, set default region if stored in an environment variable
    # export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"

    # Verify if credentials were successfully exported
    if [[ -z $AWS_ACCESS_KEY_ID ]] || [[ -z $AWS_SECRET_ACCESS_KEY ]]; then
        echo "Failed to fetch AWS credentials. Aborting..."
        exit 1
    else
        echo "AWS credentials fetched successfully."
    fi
}


# Function to change to the infrastructure directory and run OpenTofu command
run_opentofu_command_in_infrastructure() {
    if [[ -z $AWS_ACCESS_KEY_ID ]] || [[ -z $AWS_SECRET_ACCESS_KEY ]]; then
        echo "AWS credentials not found. Aborting..."
        exit 1
    fi

    # Change to the infrastructure directory
    echo "Changing to infrastructure directory: $INFRASTRUCTURE_DIR"
    cd "$INFRASTRUCTURE_DIR" || exit

    # Run the OpenTofu command passed to the script
    echo "Running OpenTofu command in $(pwd): $*"
    "$@"
}

# Main function to orchestrate the script's flow
main() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: $0 <opentofu_command> [args...]"
        exit 1
    fi

    fetch_aws_credentials
    run_opentofu_command_in_infrastructure "$@"
}

# Execute the main function with all passed arguments
main "$@"
