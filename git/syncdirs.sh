#!/usr/bin/env bash
# syncdirs.sh
# Sync subdirectory repos with GitHub

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
source "${SCRIPT_PATH}"/../colors.sh

for dir in */; do 
  echo 
  color_echo "${B_YELLOW}" "Directory >>> $dir" 
  cd $dir 
  git status && git pull && git push
  cd ..
done
