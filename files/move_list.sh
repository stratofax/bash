#!/bin/bash

# turn on unoffical bash strict mode
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

WORK_DIR="/Users/neil/Library/CloudStorage/GoogleDrive-wordpress@nhcc.net/My Drive/selected/"
ERR_DIR="/Users/neil/Library/CloudStorage/GoogleDrive-wordpress@nhcc.net/My Drive/deselected/"

# read the list of files into an array
# readarray is for bash 4 only!
# readarray -t FILES_TO_MOVE < <(cat "errors.txt")

FILES_TO_MOVE=()
while IFS= read -r line; do
    FILES_TO_MOVE+=("$line")
done < "errors.txt"
while IFS= read -r line; do
    FILES_TO_MOVE+=("$line")
done < "no_people.txt"

if [ ! -d "$ERR_DIR" ]; then
    mkdir -p "$ERR_DIR"
fi

# for each file in the list
for file in "${FILES_TO_MOVE[@]}"; do
    # move the file
    mv "$WORK_DIR$file" "$ERR_DIR"
    color_echo "${GREEN}" "Moved $WORK_DIR$file to $ERR_DIR"
done