#!/bin/bash

# turn on output for debugging
#set -x
# turn off output for production
set +x
# turn on unoffical bash strict mode
set -euo pipefail

# Define repository owner
OWNER="cadentdev"
REPO_ROOT="${HOME}/Repos/"

# Change to the parent directory containing all repos
cd "${REPO_ROOT}${OWNER}" || exit

# Loop through each directory
for dir in */; do
    # Remove trailing slash from directory name
    REPO_NAME=${dir%/}
    
    echo "Processing repository: $REPO_NAME"
    
    # Change into the repository directory
    cd "$REPO_NAME" || continue
    
    # Display current remotes
    echo "Current remotes:"
    git remote -v
    
    # Prompt for confirmation
    read -p "Continue with updating remote for $REPO_NAME? (y/n) " -n 1 -r
    echo    # Move to a new line
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Set the new remote URL
        git remote set-url origin "git@github.com:$OWNER/$REPO_NAME.git"
        
        # Display updated remotes
        echo "Updated remotes:"
        git remote -v
    else
        echo "Skipping $REPO_NAME"
    fi
    
    # Return to parent directory
    cd ..
    
    echo "----------------------------------------"
done

echo "All repositories processed"