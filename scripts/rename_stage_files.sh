#!/bin/sh

# Renames files in a directory based on a list of file names and an action (include or exclude)
# Usage: ./scripts/rename_stage_files.sh <directory_path> <include|exclude> <list_file_name>...

# Ensures there is a newline at the end of the file
ensure_newline() {
    [ -n "$(tail -c 1 "$1")" ] && echo >> "$1"
}

# Renames a single file based on the action
rename_file() {
    local file="$1"
    local action="$2"
    local directory="$3"

    local current_file="${directory}${file}"
    
    if [ "$action" = "exclude" ]; then
        [ -f "$current_file" ] && mv "$current_file" "${current_file}.exclude"
    elif [ "$action" = "include" ]; then
        [ -f "${current_file}.exclude" ] && mv "${current_file}.exclude" "$current_file"
    fi
}

# Renames files based on the list file and action
process_list_file() {
    local list_file="$1"
    local action="$2"
    local directory="$3"
    
    [ -f "$list_file" ] || { echo "List file not found: $list_file"; return 1; }
    
    ensure_newline "$list_file"
    
    while IFS= read -r file; do
        rename_file "$file" "$action" "$directory"
    done < "$list_file"
}

# Main script execution
main() {
    [ $# -lt 3 ] && { echo "Usage: $0 <directory_path> <include|exclude> <list_file_name>..."; exit 1; }
    
    local directory="$1"
    local action="$2"
    shift 2
    
    [ "${directory: -1}" != "/" ] && directory+="/"
    
    for list_file in "$@"; do
        process_list_file "${directory}${list_file}" "$action" "$directory"
    done
}

main "$@"