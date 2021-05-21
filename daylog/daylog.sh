#!/bin/bash
# daylog.sh creates a file in the specified directory 
# and opens it with your favorite editor

# what script is running?
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
CONFIG_PATH=~/'.config/daylog'
CONFIG_HERE=$CONFIG_PATH/$CONFIG_FILE 

# Check for external config file
if [ ! -f $CONFIG_HERE ]; then
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
    source $CONFIG_HERE
fi

# Check for daylog directory
## Remove trailing slash
daylog_dir=${daylog_dir%/}
if [ ! -d $daylog_dir ]; then
    echo "Daylog directory not found:"
    echo $daylog_dir
    echo $EXIT_MSG
    exit $E_NO_REPO
fi

# Check for repository directory
## Remove trailing slash
repo_dir=${repo_dir%/}
if [ ! -d $repo_dir ]; then
    echo "Repository directory not found:"
    echo $repo_dir
    echo $EXIT_MSG
    exit $E_NO_DAYLOG
fi

# Strings: filename for today's daylog, full path, time stamp
DAYLOG_NAME="log-$(date +%Y-%m-%d).md"
PATH_FILE="$daylog_dir/$DAYLOG_NAME"
TIME_STAMP="## $(date +%H:%M)"

# What this script is going to do now
echo "Create a new daylog file, $DAYLOG_NAME, if needed,"
echo "in directory: $daylog_dir;" 
echo "then edit with $EDITOR_APP."

# Before we make any changes to the local repo, pull updates
cd "$repo_dir"
echo "Working in repository:"
pwd
echo "Pulling the latest changes with rebase ..."
git pull --rebase
E_PULL=$?
# if it's not zero, there's a problem with the pull 
if [ $E_PULL -ne 0 ]; then
    echo "Error pulling from repository."
    # TODO: ask to continue
    echo $EXIT_MSG
    exit $E_PULL
fi

# Append an H2 timestamp to today's daylog file
echo "Appending time stamp to log file ..."
echo $TIME_STAMP >> $PATH_FILE
echo "File updated, now opening with $EDITOR_APP ..."

# Open today's daylog in the specified editor
E_EDITED=$("$EDITOR_APP" "$PATH_FILE")
WORD_COUNT=$(wc -w $PATH_FILE | awk '{print $1}')
echo "Edits complete: $WORD_COUNT words saved."

# stage and push to git
# TODO: git status check for changes
git add $PATH_FILE
git_msg="Daily log file update by daylog.sh"
git commit -m "$git_msg"
git push
