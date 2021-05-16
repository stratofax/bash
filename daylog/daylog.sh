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
    echo "Using default configuration settings."
    # set default values
    # DO NOT enclose the tilde character ("~") in quotes (double or single)
    # as this prevents path expansion. To specify a directory name with 
    # spaces, add the quotes AFTER the tidle, like this:
    # ~/'some path/with spaces/in it'
    repo_dir=~/'repos/writing/'
    daylog_dir=~/'repos/writing/daylogs/'
    EDITOR_APP="gvim"
else
    source $CONFIG_FILE
fi

# Check for daylog directory
# Remove trailing slash
daylog_dir=${daylog_dir%/}
if [ ! -d $daylog_dir ]; then
    echo "Daylog directory not found:"
    echo $daylog_dir
    echo $EXIT_MSG
    exit $E_NO_REPO
fi

# Check for repository directory
# Remove trailing slash
repo_dir=${repo_dir%/}
if [ ! -d $repo_dir ]; then
    echo "Repository directory not found:"
    echo $repo_dir
    echo $EXIT_MSG
    exit $E_NO_DAYLOG
fi

DAYLOG_NAME="log-$(date +%Y-%m-%d).md"

echo "Create a new daylog file, $DAYLOG_NAME, in directory:"
echo "$daylog_dir; then edit with $EDITOR_APP."

cd "$repo_dir"
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
PATH_FILE="$daylog_dir/$DAYLOG_NAME"
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
