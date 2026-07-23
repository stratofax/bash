#!/bin/bash

#######################################
# Rename files replacing search string with replacement string
# Usage: ./replace_in_filename.sh [directory]
#######################################

# turn off output for production
set +x
# turn on unofficial bash strict mode
set -euo pipefail
#######################################

# Configuration variables for search and replace
SEARCH_STRING=" "
REPLACE_STRING="_"

# Get script path for sourcing libraries
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source colors for terminal output
source "${SCRIPT_PATH}"/../lib/colors.sh

# Set IFS for safe word splitting
IFS=$'\n\t'

# Function to display help
show_help() {
    echo "Usage: $0 [DIRECTORY]"
    echo ""
    echo "Rename files in the specified directory by replacing '${SEARCH_STRING}' with '${REPLACE_STRING}' in filenames."
    echo ""
    echo "Arguments:"
    echo "  DIRECTORY    Directory to process (default: current directory)"
    echo ""
    echo "Options:"
    echo "  -h, --help   Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                      # Process current directory"
    echo "  $0 /path/to/directory   # Process specific directory"
}

# Parse command line arguments
target_dir="${1:-.}"

if [[ "$target_dir" == "-h" || "$target_dir" == "--help" ]]; then
    show_help
    exit 0
fi

# Check if directory exists
if [[ ! -d "$target_dir" ]]; then
    color_echo "$RED" "Error: Directory '$target_dir' does not exist."
    exit 1
fi

# Change to target directory
cd "$target_dir"

color_echo "$BLUE" "Processing files in directory: $(pwd)"

# Counter for renamed files
renamed_count=0

# Loop through all files in the directory (non-recursive)
for file in *; do
    # Skip if no files match the pattern (when * doesn't expand)
    [[ -e "$file" ]] || continue

    # Skip directories
    [[ -f "$file" ]] || continue

    # Check if filename contains the search string
    if [[ "$file" == *"$SEARCH_STRING"* ]]; then
        # Create new filename by replacing all occurrences of search string with replace string
        new_name="${file//$SEARCH_STRING/$REPLACE_STRING}"

        # Check if target file already exists
        if [[ -e "$new_name" ]]; then
            color_echo "$YELLOW" "Warning: Target file '$new_name' already exists. Skipping '$file'."
            continue
        fi

        # Rename the file
        mv "$file" "$new_name"
        color_echo "$GREEN" "Renamed: '$file' → '$new_name'"
        ((renamed_count++))
    fi
done

# Summary
if [[ $renamed_count -eq 0 ]]; then
    color_echo "$YELLOW" "No files with '${SEARCH_STRING}' pattern found in the directory."
else
    color_echo "$GREEN" "Successfully renamed $renamed_count file(s)."
fi