#!/bin/bash

# turn on unofficial bash strict mode
set -euo pipefail
IFS=$'\n\t'

# what script is running?
basename "$0"

#######################################
# Set up constants
#######################################
SCRIPT_PATH=$(dirname "$0")
# Add color constants and color_echo function
source "${SCRIPT_PATH}"/../lib/colors.sh

# Configuration file settings
CONFIG_FILE="movelist.cfg"
CONFIG_PATH="${HOME}/.config/movelist"
CONFIG_HERE="${CONFIG_PATH}/${CONFIG_FILE}"

# Default values that can be overridden by config file
DEFAULT_WORK_DIR="${HOME}/selected"
DEFAULT_ERR_DIR="${HOME}/deselected"

# Check for external config file
if [ ! -f "$CONFIG_HERE" ]; then
    color_echo "${YELLOW}" "Configuration file not found:"
    color_echo "${B_YELLOW}" "${CONFIG_FILE}"
    color_echo "${YELLOW}" "Creating default configuration..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$CONFIG_PATH"
    # Set restrictive permissions on config directory
    chmod 700 "$CONFIG_PATH"
    
    # Create default config file with restrictive permissions
    umask 077  # Only owner can read/write new files
    cat > "$CONFIG_HERE" << EOL
# movelist configuration file
# Created on $(date +%Y-%m-%d)

# Directory containing files to process
WORK_DIR='${DEFAULT_WORK_DIR}'

# Directory for moved files
ERR_DIR='${DEFAULT_ERR_DIR}'
EOL
    
    # Create default directories with appropriate permissions
    mkdir -p "${DEFAULT_WORK_DIR}" "${DEFAULT_ERR_DIR}"
    chmod 700 "${DEFAULT_WORK_DIR}" "${DEFAULT_ERR_DIR}"
    
    color_echo "${GREEN}" "Default configuration created at: ${CONFIG_HERE}"
    color_echo "${GREEN}" "Please edit this file to set your preferred directories."
    color_echo "${GREEN}" "Configuration file permissions set to owner-only access."
    exit 0
else
    # Check config file permissions
    if [ "$(stat -c %a "$CONFIG_HERE")" != "600" ]; then
        color_echo "${YELLOW}" "Warning: Fixing insecure permissions on config file"
        chmod 600 "$CONFIG_HERE"
    fi
    
    color_echo "${GREEN}" "Using configuration file:"
    color_echo "${B_GREEN}" "$CONFIG_HERE"
    # Source the configuration file
    # shellcheck source=/dev/null
    source "$CONFIG_HERE"
fi

# Verify required directories exist and have proper permissions
for dir in "$WORK_DIR" "$ERR_DIR"; do
    if [ ! -d "$dir" ]; then
        color_echo "${YELLOW}" "Creating directory: ${dir}"
        mkdir -p "$dir"
        chmod 700 "$dir"
    fi
    # Check directory permissions
    if [ "$(stat -c %a "$dir")" != "700" ]; then
        color_echo "${YELLOW}" "Warning: Fixing insecure permissions on ${dir}"
        chmod 700 "$dir"
    fi
done

# Array to store files to move
FILES_TO_MOVE=()

# Check if input files exist
for input_file in "errors.txt" "no_people.txt"; do
    if [ -f "$input_file" ]; then
        while IFS= read -r line; do
            FILES_TO_MOVE+=("$line")
        done < "$input_file"
    else
        color_echo "${YELLOW}" "Warning: ${input_file} not found, skipping..."
    fi
done

# Check if we found any files to move
if [ ${#FILES_TO_MOVE[@]} -eq 0 ]; then
    color_echo "${YELLOW}" "No files found to move!"
    exit 0
fi

# Move the files
for file in "${FILES_TO_MOVE[@]}"; do
    source_file="${WORK_DIR}/${file}"
    if [ -f "$source_file" ]; then
        mv "$source_file" "$ERR_DIR"
        color_echo "${GREEN}" "Moved: ${file}"
    else
        color_echo "${RED}" "Not found: ${file}"
    fi
done

color_echo "${B_GREEN}" "File movement complete!"