#!/bin/bash

# turn on output for debugging
#set -x
# turn off output for production
set +x
# turn on unoffical bash strict mode
set -euo pipefail
#######################################

# The directories we need to save
SCRIPT_DIR=$(dirname "$0")
CURRENT_DIR=$(pwd)
REPO_DIR="${HOME}/Repos/"

# Add color constants and color_echo function
source "${SCRIPT_DIR}"/../lib/colors.sh

cd "${REPO_DIR}"
echo "Working in repository directory:"
color_echo "${GREEN}" "$(pwd)"

for dir in */; do
  echo
  color_echo "${B_YELLOW}" "Directory >> $dir"
  cd "$dir"
  "${SCRIPT_DIR}"/syncdirs.sh
  cd ..
done

cd "${CURRENT_DIR}"

