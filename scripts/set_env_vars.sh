#!/bin/bash

# Path to the key-value configuration file
CONFIG_FILE="env_vars.conf"

# Function to export environment variables from the configuration file
export_env_vars() {
    if [[ -f "$CONFIG_FILE" ]]; then
        echo "Setting environment variables from $CONFIG_FILE..."
        while IFS='=' read -r key value; do
            # Export only if key is not empty and line is not a comment
            if [[ ! -z "$key" && ! $key == \#* ]]; then
                export "$key=$value"
                echo "Exported $key"
            fi
        done < "$CONFIG_FILE"
    else
        echo "Configuration file $CONFIG_FILE not found."
        exit 1
    fi
}

export_env_vars
