#!/bin/bash

# Define the base directory
base_dir="/Volumes/ExtSSD/Media/NHCC/"
move_dir="/Volumes/ExtSSD/Media/NHCC/out"
patterns="webp .bk. rotated scaled"

echo "Move all the $patterns files in the $base_dir subdirectories"
echo "to $move_dir"

# Create the move directory if it doesn't exist
if [ ! -d "$move_dir" ]; then
    mkdir -p "$move_dir"
fi

# Get the list of subdirectories using ls -d
sub_dirs=$(ls -d "$base_dir"/*/)

# Loop through each subdirectory
for sub_dir in $sub_dirs; do
    # Check if it is a directory (this is mostly redundant since ls -d should only list directories)
    if [ -d "$sub_dir" ]; then
        # Change to the subdirectory
        cd "$sub_dir" || exit
        pwd


        # Move files in pattern list
        for pattern in $patterns; do
            echo "Moving files with pattern: $pattern"
            move_these=$(ls -f ./*"$pattern"*)
            if [ -z "$move_these" ]; then
                echo "Nothing to move";
            else
                for file_name in $move_these; do
                    if [ ! -f "$file_name" ]; then
                       mv "$file_name" "$move_dir"
                    fi
                done
            fi
        done

        glob_list=$(ls | grep -E '[0-9]+x[0-9]+')
        for glob_file in $glob_list; do
            if [ ! -f "$glob_file" ]; then
                mv "$glob_file" "$move_dir"
            fi
        done

        # Go back to the base directory
        cd - > /dev/null || exit
    fi
done
