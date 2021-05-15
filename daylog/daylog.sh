#!/bin/bash
# daylog.sh creates a file in the specified directory 
# and opens it with your favorite editor

echo $(basename $0)
#######################################
# Set up constants
#######################################
# TODO: Set default values for config vars
# Error codes
E_NO_CONFIG=101
E_NO_REPO=102
E_NO_DAYLOG=103

# Strings and filenames
EXIT_MSG="Script terminated."
CONFIG_FILE="daylog.cfg"


if [ ! -f $CONFIG_FILE ]; then
    echo "Configuration file $CONFIG_FILE not found."
    echo $EXIT_MSG
    exit $E_NO_CONFIG
fi
source $CONFIG_FILE

# Check for repository directory
# Remove trailing slash
DAYLOG_DIR="${DAYLOG_DIR%/}"
if [ ! -d $DAYLOG_DIR ]; then
    echo "Daylog directory not found:"
    echo $DAYLOG_DIR
    echo $EXIT_MSG
    exit $E_NO_REPO
fi

# Check for repository directory
# Remove trailing slash
REPO_DIR="${REPO_DIR%/}"
if [ ! -d $REPO_DIR ]; then
    echo "Repository directory not found:"
    echo $REPO_DIR
    echo $EXIT_MSG
    exit $E_NO_DAYLOG
fi

DAYLOG_NAME="log-$(date +%Y-%m-%d).md"

echo "Create a new daylog file, $DAYLOG_NAME, in directory:"
echo "$DAYLOG_DIR; then edit with $EDITOR_APP."

cd "$REPO_DIR"
echo "Working in repository:"
pwd
echo "Pulling the latest changes using rebase ..."
git pull --rebase
E_PULL=$?
# if it's not zero, it's an error
if [ $E_PULL -ne 0 ]; then
    # ask to continue
    echo "Error pulling from repository."
    echo $EXIT_MSG
    exit $E_PULL
fi
# Append an H2 timestamp to the file
TIME_STAMP="## $(date +%H:%M)"
PATH_FILE="$DAYLOG_DIR/$DAYLOG_NAME"
echo "Appending time stamp to log file ..."
echo $TIME_STAMP >> $PATH_FILE
echo "File updated, now opening with $EDITOR_APP ..."
E_EDITED=$("$EDITOR_APP" "$PATH_FILE")
echo "Edits completed. $E_EDITED"
# stage and push to git
# TODO: git status check for changes
git add $PATH_FILE
git_msg="Update by daylog.sh"
git commit -m "$git_msg"
git push
