#!/bin/bash

# This script processes all .wav files in the current directory
# using the 'whisper' command and times each execution.

# Check if 'whisper' command exists
if ! command -v whisper &> /dev/null
then
    echo "Error: 'whisper' command not found."
    echo "Please ensure whisper is installed and accessible in your PATH."
    exit 1
fi

# Check if there are any .wav files in the current directory
shopt -s nullglob # This prevents the loop from running on "*.wav" if no files match
files=(*.wav)
shopt -u nullglob # Turn nullglob off after use

if [ ${#files[@]} -eq 0 ]; then
    echo "No .wav files found in the current directory."
    exit 0
fi

echo "--- Starting Whisper processing for .wav files ---"
echo "Results will show 'real', 'user', and 'sys' time for each file."
echo "----------------------------------------------------"

# Loop through each .wav file
for file in "${files[@]}"; do
    if [ -f "$file" ]; then # Ensure it's a regular file and not a directory etc.
        echo "" # Add a blank line for readability
        echo "Processing: $file"
        echo "----------------------------------------------------"
        time whisper "$file" --model turbo --language English
        echo "----------------------------------------------------"
    fi
done

echo ""
echo "--- All .wav files processed ---"