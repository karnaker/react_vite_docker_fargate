#!/bin/bash

# Script to fetch the AWS account ID using AWS CLI

# Define function to get AWS account ID
get_aws_account_id() {
    # Fetch the AWS Account ID
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

    # Check for errors
    if [ $? -ne 0 ]; then
        echo "Error fetching AWS Account ID. Make sure AWS CLI is configured correctly."
        exit 1
    fi

    # Print the fetched AWS Account ID
    echo "AWS Account ID: $AWS_ACCOUNT_ID"
}

get_aws_account_id