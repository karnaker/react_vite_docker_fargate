#!/bin/sh

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

# Execute the fetch credentials function
fetch_aws_credentials
