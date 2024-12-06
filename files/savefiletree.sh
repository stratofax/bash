#!/bin/bash

# Exit on error, unset variables, and pipe failures
set -euo pipefail

# Default values
DEFAULT_SOURCE_DIR="."
DEFAULT_OUTPUT_DIR="${HOME}/output"
EXCLUDE_PATTERNS=()

function print_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]
Consolidates text files into a single file and generates a directory tree.

Options:
  -d, --directory DIR    Source directory (default: current directory)
  -o, --output DIR       Output directory (default: ~/output)
  -e, --exclude PATTERN  Additional exclude pattern (can be used multiple times)
  -h, --help             Display this help message
EOF
}

function verify_requirements() {
    local required_cmds=("tree" "find")
    
    for cmd in "${required_cmds[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "Error: Required command '$cmd' not found. Please install it first."
            exit 1
        fi
    done
}

function parse_arguments() {
    local OPTIND
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--directory) source_dir="$2"; shift 2 ;;
            -o|--output)    output_dir="$2"; shift 2 ;;
            -e|--exclude)   EXCLUDE_PATTERNS+=("$2"); shift 2 ;;
            -h|--help)      print_usage; exit 0 ;;
            *)             echo "Error: Unknown option $1"; print_usage; exit 1 ;;
        esac
    done
}

function setup_directories() {
    if [[ ! -d "$source_dir" ]]; then
        echo "Error: Source directory '$source_dir' does not exist."
        exit 1
    fi
    mkdir -p "$output_dir"
}

function generate_filenames() {
    local date_suffix
    date_suffix=$(date +%Y-%m-%d_%H-%M-%S)
    output_file="${output_dir}/file_contents_${date_suffix}.txt"
    tree_file="${output_dir}/tree_${date_suffix}.txt"
}

function write_header() {
    cat << EOF > "$output_file"
=== File Contents Consolidated on $(date '+%Y-%m-%d %H:%M:%S') ===
Source Directory: $(realpath "$source_dir")
==================================================

EOF
}

function process_files() {
    local find_excludes=(-not -path '*/\.*' -not -path "./${output_dir}/*")
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        find_excludes+=(-not -path "*/$pattern*")
    done

    find "$source_dir" -type f "${find_excludes[@]}" -exec file {} \; | 
        grep -i "text" | 
        cut -d: -f1 | 
        while read -r file; do
            local relpath
            relpath=$(realpath --relative-to="$source_dir" "$file")
            {
                echo -e "\n=== $relpath ==="
                echo -e "Last modified: $(stat -c %y "$file")"
                echo -e "Size: $(stat -c %s "$file") bytes"
                echo -e "===================\n"
                cat "$file"
            } >> "$output_file"
        done
}

function generate_tree() {
    {
        echo "=== Directory Tree Generated on $(date '+%Y-%m-%d %H:%M:%S') ==="
        echo "Source Directory: $(realpath "$source_dir")"
        echo "=================================================="
        echo
        tree --dirsfirst -I "${output_dir##*/}" "$source_dir" --noreport |
            grep -v "^\.$" |
            grep -v "^\.\." |
            grep -v "^\.git" |
            grep -v "^\.[a-zA-Z]"
    } > "$tree_file"
}

function print_summary() {
    echo -e "\nSummary:"
    echo "- File contents written to: $output_file"
    echo "- Directory tree written to: $tree_file"
    echo "- Total files processed: $(grep -c "^===" "$output_file")"
    echo "- Total size: $(du -h "$output_file" | cut -f1)"
}

# Main execution
source_dir="$DEFAULT_SOURCE_DIR"
output_dir="$DEFAULT_OUTPUT_DIR"

verify_requirements
parse_arguments "$@"
setup_directories
generate_filenames
write_header
echo "Consolidating files..."
process_files
echo "Generating directory tree..."
generate_tree
print_summary