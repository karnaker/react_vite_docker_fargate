#!/bin/sh

# Script to load variables from a Terraform variables file (tfvars)

# Define a function to load variables
load_variables_from_tfvars() {
    local tfvars_file="$1"
    
    # Check if tfvars file exists
    if [[ ! -f "$tfvars_file" ]]; then
        echo "Error: '$tfvars_file' does not exist."
        return 1
    fi

    echo "Loading variables from $tfvars_file..."
    
    # Extract and export variables
    while IFS='=' read -r key value; do
        # Remove spaces around '=' and trim whitespace from value
        key=$(echo "$key" | xargs | tr '[:lower:]' '[:upper:]')
        value=$(echo "$value" | sed -e 's/^ *//' -e 's/ *$//' -e 's/^"//' -e 's/"$//' -e 's/^`//' -e 's/`$//')
        
        # Check for non-empty key and not a comment
        if [[ ! -z "$key" && ! "$key" =~ ^\# ]]; then
            export "$key"="$value"
            echo "Exported $key=$value"
        fi
    done < "$tfvars_file"
}

# Usage example:
# load_variables_from_tfvars "./infrastructure/ecs_fargate/ecs_fargate_dev.tfvars"

# Uncomment the line below to execute the function with a specific tfvars file
load_variables_from_tfvars "$1"
