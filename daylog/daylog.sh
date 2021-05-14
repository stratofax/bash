#!/bin/bash
# daylog.sh creates a file in the specified directory 
# and opens it with your favorite editor

source daylog.cfg
DAYLOG_NAME="log-$(date +%Y-%m-%d).md"

echo $0
echo "Creates a new daylog file $DAYLOG_NAME in directory"
echo "$DAYLOG_DIR and edit with $EDITOR_APP"

cd "$REPO_DIR"

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
echo $TIME_STAMP >> "$DAYLOG_DIR$DAYLOG_NAME"
$("$EDITOR_APP) $DAYLOG_DIR$DAYLOG_NAME"
