#!/bin/bash

echo "Attemping to push and pull changes in directory:"
pwd
echo "Pulling the latest changes using rebase ..."
git pull --rebase
E_PULL=$?
# if it's not zero, it's an error
if [ $E_PULL -ne 0 ]; then
    echo "Error $E_PULL - update cancelled."
    exit $E_PULL
fi
echo "Checking for local changes to push ..."
changed_files=$(git status -s)
E_STATUS=$?
# if it's not zero, it's an error
if [ $E_STATUS -ne 0 ]; then
    echo "Error $E_STATUS - update cancelled."
    exit $E_STATUS
else
    if [ $#changed_files ]; then
        echo "$changed_files"
        # "Add all changed files?" 
        # read -p "Enter Y to add, N to exit: " addFiles
    fi
fi