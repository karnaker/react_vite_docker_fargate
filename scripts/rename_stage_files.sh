#!/bin/sh

# Function to rename files based on the action argument
rename_files() {
    local action="$1"
    local directory="./infrastructure/ecs_fargate/"
    local list_file="./infrastructure/ecs_fargate/stage2_files.list"

    # Check if list file exists
    if [ ! -f "$list_file" ]; then
        echo "List file not found: $list_file"
        exit 1
    fi

    # Read each line from the list file
    while IFS= read -r file; do
        # Debug: Print the file name being processed
        echo "Processing $file..."

        # Check if file exists
        if [ ! -f "${directory}${file}" ] && [ ! -f "${directory}${file}.exclude" ]; then
            echo "File not found: ${directory}${file}"
            continue
        fi

        if [ "$action" == "exclude" ]; then
            # Rename *.tf to *.tf.exclude
            mv "${directory}${file}" "${directory}${file}.exclude"
            echo "Renamed ${file} to ${file}.exclude"
        elif [ "$action" == "include" ]; then
            # Rename *.tf.exclude to *.tf
            mv "${directory}${file}.exclude" "${directory}${file}"
            echo "Renamed ${file}.exclude to ${file}"
        else
            echo "Invalid action specified. Please use 'include' or 'exclude'."
            exit 1
        fi
    done < "$list_file"
}

# Main script execution
if [ $# -ne 1 ]; then
    echo "Usage: $0 <include|exclude>"
    exit 1
fi

action=$1
rename_files $action
