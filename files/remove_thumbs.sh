#!/bin/bash

source ../lib/colors.sh

# Define the settings
BASE_DIR="/Volumes/ExtSSD/Media/NHCC/slideshow/2024"
MOVE_DIR="/Volumes/ExtSSD/Media/NHCC/slideshow/out"
PATTERNS="webp .bk. rotated scaled"

# Function to move files
move_files() {
    local filename="$1"
    local movedir="$2"
    if [ -f "$filename" ]; then
        mv "$filename" "$movedir"
        color_echo "${GREEN}" "Moved $filename to $movedir"
    fi
}

echo "Move all the $PATTERNS files in the $BASE_DIR subdirectories"
echo "to $MOVE_DIR"

# Create the move directory if it doesn't exist
if [ ! -d "$MOVE_DIR" ]; then
    mkdir -p "$MOVE_DIR"
fi

# Get the list of subdirectories
sub_dirs=$(ls -d "$BASE_DIR"/*/)

# Loop through each subdirectory
for sub_dir in $sub_dirs; do
    # Check if it is a directory (this is mostly redundant since ls -d should only list directories)
    if [ -d "$sub_dir" ]; then
        # Change to the subdirectory or skip to the next item
        cd "$sub_dir" || exit
        color_echo "${I_YELLOW}" "Moving files in subdirectory:"
        pwd

        # Move files in pattern list
        for pattern in $PATTERNS; do
            color_echo "${YELLOW}" "Moving files with pattern: $pattern"
            move_these=$(ls -f ./*"$pattern"*)
            if [ -z "$move_these" ]; then
                color_echo "${I_YELLOW}" "Nothing to move";
            else
                for file_name in $move_these; do
                    move_files "$file_name" "$MOVE_DIR"
                done
            fi
        done

        # move thumbnail files labelled with pixel dimensions
        glob_list=$(ls | grep -E '[0-9]+x[0-9]+')
        for glob_file in $glob_list; do
            move_files "$glob_file" "$MOVE_DIR"
        done

        # Go back to the base directory
        cd - > /dev/null || exit
    fi
done

color_echo "${BI_GREEN}" "All directories processed."