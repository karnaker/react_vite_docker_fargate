#!/bin/sh

# Function to ensure there is a newline at the end of the list file
ensure_newline_at_end_of_file() {
    local file="$1"
    # Read the last byte of the file
    last_char=$(tail -c 1 "$file")
    # If the last character is not a newline, add one
    if [ "$last_char" != "" ]; then
        echo '' >> "$file"
    fi
}

# Function to rename files based on the action argument and specified directory and list file
rename_files() {
    local action="$1"
    local directory="$2"
    local list_file="$3"

    # Ensure trailing slash on directory path
    [ "${directory: -1}" != "/" ] && directory="$directory/"

    # Full path to the list file
    local full_list_file="${directory}${list_file}"

    # Ensure there is a newline at the end of the list file
    ensure_newline_at_end_of_file "$full_list_file"

    # Check if list file exists
    if [ ! -f "$full_list_file" ]; then
        echo "List file not found: $full_list_file"
        exit 1
    fi

    # Read each line from the list file
    while IFS= read -r file; do
        echo "Processing $file..."

        # Determine the full path to the current file
        local current_file="${directory}${file}"

        # Check if the file exists
        if [ ! -f "$current_file" ] && [ ! -f "${current_file}.exclude" ]; then
            echo "File not found: $current_file"
            continue
        fi

        if [ "$action" == "exclude" ]; then
            # Rename *.tf to *.tf.exclude
            mv "$current_file" "${current_file}.exclude"
            echo "Renamed $file to ${file}.exclude"
        elif [ "$action" == "include" ]; then
            # Rename *.tf.exclude to *.tf
            mv "${current_file}.exclude" "$current_file"
            echo "Renamed ${file}.exclude to $file"
        else
            echo "Invalid action specified. Please use 'include' or 'exclude'."
            exit 1
        fi
    done < "$full_list_file"
}

# Main script execution
if [ $# -ne 3 ]; then
    echo "Usage: $0 <include|exclude> <directory_path> <list_file_name>"
    exit 1
fi

action="$1"
directory_path="$2"
list_file_name="$3"

rename_files "$action" "$directory_path" "$list_file_name"
