#!/bin/bash

# Exit on any error
set -e

# Function to display usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Consolidates text files into a single file and generates a directory tree."
    echo
    echo "Options:"
    echo "  -d, --directory DIR    Source directory (default: current directory)"
    echo "  -o, --output DIR       Output directory (default: ./output)"
    echo "  -e, --exclude PATTERN  Additional exclude pattern (can be used multiple times)"
    echo "  -h, --help            Display this help message"
}

# Function to check if a command exists
check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: Required command '$1' not found. Please install it first."
        exit 1
    fi
}

# Parse command line arguments
SOURCE_DIR="."
OUTPUT_DIR=~/output
EXCLUDE_PATTERNS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--directory)
            SOURCE_DIR="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -e|--exclude)
            EXCLUDE_PATTERNS+=("$2")
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Error: Unknown option $1"
            usage
            exit 1
            ;;
    esac
done

# Check for required commands
check_command tree
check_command find

# Validate source directory
if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Generate the output filenames using current date and time in ISO format
date_suffix=$(date +%Y-%m-%d_%H-%M-%S)
output_file="$OUTPUT_DIR/file_contents_${date_suffix}.txt"
tree_file="$OUTPUT_DIR/tree_${date_suffix}.txt"

# Build find exclusion patterns
FIND_EXCLUDES=(-not -path '*/\.*' -not -path "./${OUTPUT_DIR}/*")
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    FIND_EXCLUDES+=(-not -path "*/$pattern*")
done

# Create header for the output file
{
    echo "=== File Contents Consolidated on $(date '+%Y-%m-%d %H:%M:%S') ==="
    echo "Source Directory: $(realpath "$SOURCE_DIR")"
    echo "=================================================="
    echo
} > "$output_file"

# Find all text files and concatenate their contents
echo "Consolidating files..."
find "$SOURCE_DIR" -type f "${FIND_EXCLUDES[@]}" -exec file {} \; | 
    grep -i "text" | 
    cut -d: -f1 | 
    while read -r file; do
        # Get the relative path
        relpath=$(realpath --relative-to="$SOURCE_DIR" "$file")
        {
            echo -e "\n=== $relpath ==="
            echo -e "Last modified: $(stat -c %y "$file")"
            echo -e "Size: $(stat -c %s "$file") bytes"
            echo -e "===================\n"
            cat "$file"
        } >> "$output_file"
    done

# Generate and save tree output
echo "Generating directory tree..."
{
    echo "=== Directory Tree Generated on $(date '+%Y-%m-%d %H:%M:%S') ==="
    echo "Source Directory: $(realpath "$SOURCE_DIR")"
    echo "=================================================="
    echo
    tree --dirsfirst -I "${OUTPUT_DIR##*/}" "$SOURCE_DIR" --noreport |
        grep -v "^\.$" |
        grep -v "^\.\." |
        grep -v "^\.git" |
        grep -v "^\.[a-zA-Z]"
} > "$tree_file"

# Print summary
echo -e "\nSummary:"
echo "- File contents written to: $output_file"
echo "- Directory tree written to: $tree_file"
echo "- Total files processed: $(grep -c "^===" "$output_file")"
echo "- Total size: $(du -h "$output_file" | cut -f1)"