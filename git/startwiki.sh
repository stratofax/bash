#!/bin/bash

#######################################
# Start the day off right with this quick automation
#######################################

# turn on output for debugging
#set -x
# turn off output for production
set +x
# turn on unoffical bash strict mode
set -euo pipefail
#######################################

SCRIPT_PATH=$(dirname "$0")
MY_REPOS_DIR="${HOME}/Repos/stratofax/"
MY_WIKI_DIR='slipbox/'

cd "${MY_REPOS_DIR}"
"${SCRIPT_PATH}"/syncdirs.sh
cd "${MY_WIKI_DIR}"
gvim &
