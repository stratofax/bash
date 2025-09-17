#!/bin/bash

#######################################
# Resize JPEG images to specified height while maintaining aspect ratio
# Usage: ./resize_images.sh [directory] [height] [quality]
# Requires: ImageMagick (checked at startup)
# Supports: ImageMagick, GraphicsMagick, and macOS sips as fallbacks
#######################################

# turn off output for production
set +x
# turn on unofficial bash strict mode
set -euo pipefail
#######################################

# Configuration variables
DEFAULT_HEIGHT=900
DEFAULT_QUALITY=85
OUTPUT_SUFFIX="_resized"

# Get script path for sourcing libraries
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source colors for terminal output
source "${SCRIPT_PATH}"/../lib/colors.sh

# Set IFS for safe word splitting
IFS=$'\n\t'

# Function to check ImageMagick installation (cross-platform)
check_imagemagick() {
    local has_convert=false
    local has_magick=false
    
    # Check for convert command (ImageMagick 6.x and 7.x)
    if command -v convert >/dev/null 2>&1; then
        has_convert=true
    fi
    
    # Check for magick command (ImageMagick 7.x)
    if command -v magick >/dev/null 2>&1; then
        has_magick=true
    fi
    
    # Verify it's actually ImageMagick (not Windows convert.exe)
    if [[ "$has_convert" == true ]]; then
        if convert -version 2>/dev/null | grep -q "ImageMagick"; then
            return 0  # ImageMagick found via convert
        fi
    fi
    
    if [[ "$has_magick" == true ]]; then
        if magick -version 2>/dev/null | grep -q "ImageMagick"; then
            return 0  # ImageMagick found via magick
        fi
    fi
    
    return 1  # ImageMagick not found
}

# Function to display help
show_help() {
    echo "Usage: $0 [DIRECTORY] [HEIGHT] [QUALITY] [-s SUFFIX]"
    echo ""
    echo "Resize JPEG images in the specified directory to the given height while maintaining aspect ratio."
    echo ""
    echo "Arguments:"
    echo "  DIRECTORY    Directory containing JPEG files (default: current directory)"
    echo "  HEIGHT       Target height in pixels (default: ${DEFAULT_HEIGHT})"
    echo "  QUALITY      JPEG quality 1-100 (default: ${DEFAULT_QUALITY})"
    echo ""
    echo "Options:"
    echo "  -h, --help   Show this help message"
    echo "  -s SUFFIX    Custom suffix for output files (default: ${OUTPUT_SUFFIX})"
    echo ""
    echo "Examples:"
    echo "  $0                           # Resize JPEGs in current dir to 900px height"
    echo "  $0 /path/to/images           # Resize JPEGs in specific directory"
    echo "  $0 /path/to/images 1200      # Resize to 1200px height"
    echo "  $0 /path/to/images 900 90    # Resize to 900px height with 90% quality"
    echo "  $0 /path/to/images -s thumb 150    # Resize to 150px height with '_thumb' suffix"
    echo "  $0 /path/to/images 150 85 -s small # Resize to 150px, 85% quality, '_small' suffix"
    echo ""
    echo "Requirements:"
    echo "  - ImageMagick must be installed (checked at startup)"
    echo ""
    echo "Supported tools (in order of preference):"
    echo "  1. ImageMagick (convert/magick) - Required"
    echo "  2. GraphicsMagick (gm) - Fallback"
    echo "  3. macOS sips (built-in) - Fallback"
}

# Function to detect available image processing tool
detect_tool() {
    # Since we've already verified ImageMagick is available, prioritize it
    if command -v magick >/dev/null 2>&1; then
        echo "imagemagick_v7"
    elif command -v convert >/dev/null 2>&1; then
        echo "imagemagick"
    elif command -v gm >/dev/null 2>&1; then
        echo "graphicsmagick"
    elif command -v sips >/dev/null 2>&1; then
        echo "sips"
    else
        echo "none"
    fi
}

# Function to resize image using detected tool
resize_image() {
    local input_file="$1"
    local output_file="$2"
    local height="$3"
    local quality="$4"
    local tool="$5"
    
    case "$tool" in
        "imagemagick")
            convert "$input_file" -resize "x${height}" -quality "$quality" "$output_file"
            ;;
        "imagemagick_v7")
            magick "$input_file" -resize "x${height}" -quality "$quality" "$output_file"
            ;;
        "graphicsmagick")
            gm convert "$input_file" -resize "x${height}" -quality "$quality" "$output_file"
            ;;
        "sips")
            # sips doesn't have quality control, so we copy and resize
            cp "$input_file" "$output_file"
            sips --resampleHeight "$height" "$output_file" >/dev/null
            ;;
        *)
            color_echo "$RED" "Error: No supported image processing tool found."
            color_echo "$YELLOW" "Please install one of: ImageMagick, GraphicsMagick"
            color_echo "$YELLOW" "macOS: brew install imagemagick"
            color_echo "$YELLOW" "       brew install graphicsmagick"
            exit 1
            ;;
    esac
}

# Parse command line arguments
target_dir="."
height="$DEFAULT_HEIGHT"
quality="$DEFAULT_QUALITY"
custom_suffix="$OUTPUT_SUFFIX"

# Process arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -s)
            if [[ -n "$2" && "$2" != -* ]]; then
                custom_suffix="_$2"
                shift 2
            else
                color_echo "$RED" "Error: -s requires a suffix argument"
                exit 1
            fi
            ;;
        -*)
            color_echo "$RED" "Error: Unknown option $1"
            exit 1
            ;;
        *)
            # Positional arguments: directory, height, quality
            if [[ "$target_dir" == "." ]]; then
                target_dir="$1"
            elif [[ "$height" == "$DEFAULT_HEIGHT" ]]; then
                height="$1"
            elif [[ "$quality" == "$DEFAULT_QUALITY" ]]; then
                quality="$1"
            else
                color_echo "$RED" "Error: Too many positional arguments"
                exit 1
            fi
            shift
            ;;
    esac
done

# Set default directory if not specified
if [[ "$target_dir" == "." ]]; then
    target_dir="."
fi

# Check ImageMagick availability upfront (cross-platform)
if ! check_imagemagick; then
    color_echo "$RED" "Error: ImageMagick is not installed or not accessible."
    color_echo "$YELLOW" "ImageMagick is required for this script to function."
    echo ""
    color_echo "$CYAN" "Installation instructions:"
    color_echo "$WHITE" "  macOS:     brew install imagemagick"
    color_echo "$WHITE" "  Ubuntu:    sudo apt-get install imagemagick"
    color_echo "$WHITE" "  CentOS:    sudo yum install ImageMagick"
    color_echo "$WHITE" "  Windows:   Download from https://imagemagick.org/script/download.php#windows"
    echo ""
    color_echo "$YELLOW" "After installation, restart your terminal and try again."
    exit 1
fi

# Validate height parameter
if ! [[ "$height" =~ ^[0-9]+$ ]] || [[ "$height" -lt 1 ]]; then
    color_echo "$RED" "Error: Height must be a positive integer."
    exit 1
fi

# Validate quality parameter
if ! [[ "$quality" =~ ^[0-9]+$ ]] || [[ "$quality" -lt 1 ]] || [[ "$quality" -gt 100 ]]; then
    color_echo "$RED" "Error: Quality must be an integer between 1 and 100."
    exit 1
fi

# Check if directory exists
if [[ ! -d "$target_dir" ]]; then
    color_echo "$RED" "Error: Directory '$target_dir' does not exist."
    exit 1
fi

# Detect available tool
tool=$(detect_tool)
if [[ "$tool" == "none" ]]; then
    color_echo "$RED" "Error: No supported image processing tool found."
    color_echo "$YELLOW" "Please install ImageMagick: brew install imagemagick"
    exit 1
fi

# Display tool being used
case "$tool" in
    "imagemagick") tool_name="ImageMagick (convert)" ;;
    "imagemagick_v7") tool_name="ImageMagick v7+ (magick)" ;;
    "graphicsmagick") tool_name="GraphicsMagick (gm)" ;;
    "sips") tool_name="macOS sips (built-in)" ;;
esac

color_echo "$BLUE" "Using tool: $tool_name"
color_echo "$BLUE" "Processing directory: $(realpath "$target_dir")"
color_echo "$BLUE" "Target height: ${height}px"
color_echo "$BLUE" "JPEG quality: ${quality}%"

# Change to target directory
cd "$target_dir"

# Create output directory if it doesn't exist
output_dir="resized_${height}px"
mkdir -p "$output_dir"

color_echo "$BLUE" "Output directory: $(pwd)/$output_dir"
echo ""

# Counter for processed files
processed_count=0
error_count=0

# Process JPEG files
for file in *.jpg *.jpeg *.JPG *.JPEG; do
    # Skip if no files match the pattern
    [[ -e "$file" ]] || continue
    
    # Skip directories
    [[ -f "$file" ]] || continue
    
    # Generate output filename
    filename=$(basename "$file")
    extension="${filename##*.}"
    name="${filename%.*}"
    output_file="${output_dir}/${name}${custom_suffix}.${extension}"
    
    # Check if output file already exists
    if [[ -e "$output_file" ]]; then
        color_echo "$YELLOW" "Skipping '$file' - output already exists"
        continue
    fi
    
    # Resize the image
    color_echo "$CYAN" "Processing: $file"
    if resize_image "$file" "$output_file" "$height" "$quality" "$tool"; then
        color_echo "$GREEN" "  ✓ Resized: $file → $output_file"
        ((processed_count++))
    else
        color_echo "$RED" "  ✗ Failed to resize: $file"
        ((error_count++))
    fi
done

echo ""

# Summary
if [[ $processed_count -eq 0 ]] && [[ $error_count -eq 0 ]]; then
    color_echo "$YELLOW" "No JPEG files found in the directory."
elif [[ $error_count -eq 0 ]]; then
    color_echo "$GREEN" "Successfully resized $processed_count image(s) to ${height}px height."
    color_echo "$GREEN" "All resized images saved to: $output_dir/"
else
    color_echo "$YELLOW" "Processed $processed_count image(s) successfully, $error_count failed."
    color_echo "$GREEN" "Resized images saved to: $output_dir/"
fi
