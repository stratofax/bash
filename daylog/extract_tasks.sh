#!/bin/bash

# Get today's date in ISO format and create the tasks file name
today=$(date +%Y-%m-%d)
tasks_file="${today}_tasks.md"

# Create the new tasks file with a header
echo "# Tasks collected on $today" > "$tasks_file"
echo "" >> "$tasks_file"

# Find all files containing the task pattern and sort them
find . -maxdepth 1 -type f -not -name "$tasks_file" -exec grep -l "^- \[ \]" {} \; | sort > .temp_files.txt

# Process each matched file
while IFS= read -r file; do
    echo "Processing: $file"
    
    # Get the first line of the file to use as a header
    header=$(head -n 1 "$file")
    
    # Append the header to tasks file
    echo "## $header" >> "$tasks_file"
    echo "" >> "$tasks_file"
    
    # Extract task lines and append to tasks file
    grep "^- \[ \]" "$file" >> "$tasks_file"
    echo "" >> "$tasks_file"
    
    # Remove task lines from the original file
    grep -v "^- \[ \]" "$file" > .temp_content
    mv .temp_content "$file"
done < .temp_files.txt

# Clean up temporary files
rm .temp_files.txt

echo "Task collection complete. All tasks have been moved to $tasks_file"
