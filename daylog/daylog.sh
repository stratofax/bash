#!/bin/bash
# daylog.sh creates a file in the specified directory 
# and opens it with your favorite editor
# TODO: Set default values for config vars
# TODO: Check for existence of config file
source daylog.cfg
DAYLOG_NAME="log-$(date +%Y-%m-%d).md"

echo $(basename $0)
echo "Create a new daylog file $DAYLOG_NAME in directory"
echo "$DAYLOG_DIR then edit with $EDITOR_APP"

cd "$REPO_DIR"
echo "Working in repository:"
pwd
echo "Pulling the latest changes using rebase ..."
git pull --rebase
E_PULL=$?
# if it's not zero, it's an error
if [ $E_PULL -ne 0 ]; then
    # ask to continue
    
    echo "Error $E_PULL - update cancelled."
    exit $E_PULL
fi
# Append an H2 timestamp to the file
TIME_STAMP="## $(date +%H:%M)"
PATH_FILE="$DAYLOG_DIR$DAYLOG_NAME"
echo "Appending time stamp to log file $PATH_FILE"
echo $TIME_STAMP >> $PATH_FILE
$("$EDITOR_APP" "$PATH_FILE")
# stage and push to git
# TODO: git status check for changes
git add $PATH_FILE
git_msg="Update by daylog.sh"
git commit -m "$git_msg"
git push
