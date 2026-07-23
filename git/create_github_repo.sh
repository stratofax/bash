#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# Project name
GITHUB_PROJECT=...
# Project owner
GITHUB_USER=...
# URL of origin
GITHUB_ORIGIN="https://github.com/${GITHUB_USER}/${GITHUB_PROJECT}.git"

# Create a local repository
git init
# Add an empty README, .gitignore and any other files
echo "# ${GITHUB_PROJECT}" >> README.md
touch .gitignore
# Other files ...
git stage README.md .gitignore
git commit -m "Initial commit (or whatever other message you want)."

# Add the remote project as the origin
git remote add origin "${GITHUB_ORIGIN}"
# Rename the current branch to 'main' if it's not main already
# '-M' is '--move --force'
git branch -M main
# Push the main branch to the origin
# '-u' is '--set-upstream'
git push -u origin main