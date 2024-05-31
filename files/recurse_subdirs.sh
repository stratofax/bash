#!/bin/bash

# recursively consolidate all the files
# in subdirectories in the base directory
# and move them to another directory

# turn on unoffical bash strict mode
# set -euo pipefail
IFS=$'\n\t'

# what script is running?
basename "$0"

#######################################
# Set up constants
#######################################
SCRIPT_PATH=$(dirname "$0")
# Add color constants and color_echo function
source "${SCRIPT_PATH}"/../lib/colors.sh

# Define the settings
BASE_DIR="/Volumes/ExtSSD/Media/NHCC/slideshow/source"
MOVE_DIR="/Volumes/ExtSSD/Media/NHCC/slideshow/selected"

# Function to check each subdirectory
recurse_dir() {
    local target_dir="$1"
    cd "$target_dir" || exit
    current_dir=$(pwd)

    # Get the list of subdirectories
    sub_dirs=$(ls -d "$current_dir"/*/ 2>/dev/null)
    # if the subdirectory is empty, exit
    # Check if the ls command was successful
    if [ $? -eq 0 ]; then
        echo "$sub_dirs"
        # Loop through each subdirectory
        for sub_dir in $sub_dirs; do
            # Check if it is a directory (this is mostly redundant since ls -d should only list directories)
            if [ -d "$sub_dir" ]; then
                # Change to the subdirectory or skip to the next item
                cd "$sub_dir" || exit
                color_echo "${I_YELLOW}" "Working in subdirectory:"
                echo "$sub_dir"
                recurse_dir "$(pwd)"
            fi
        done
    else
        echo "No subdirectories found in: $current_dir"
        # Go back to the base directory
        cd - > /dev/null || exit
        return
    fi
}

# Confirm the specified base directory exists
if [ ! -d "$BASE_DIR" ]; then
    color_echo "${RED}" "The base directory was not found: $BASE_DIR"
    echo "Script terminated."
    exit
fi

# Create the move directory if it doesn't exist
if [ ! -d "$MOVE_DIR" ]; then
    mkdir -p "$MOVE_DIR"
    color_echo "${GREEN}" "Output directory created: $MOVE_DIR"
fi

# start in the base directory
recurse_dir "$BASE_DIR"