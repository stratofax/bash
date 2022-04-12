#!/bin/bash
# daylog.sh creates a file in the specified directory
# and opens it with your favorite editor

# turn on unoffical bash strict mode
set -euo pipefail
IFS=$'\n\t'

# what script is running?
basename "$0"
#######################################
# Set up constants
#######################################
# Color codes
# Use "033" instead of "e"
RESET='\033[0m'       # Text Reset
BOLD="\033[1m"              # bold
# Regular Colors
BLACK='\033[0;30m'        # Black
RED='\033[0;31m'          # Red
GREEN='\033[0;32m'        # Green
YELLOW='\033[0;33m'       # Yellow
BLUE='\033[0;34m'         # Blue
PURPLE='\033[0;35m'       # Purple
CYAN='\033[0;36m'         # Cyan
WHITE='\033[0;37m'        # White

# Error codes
E_NO_REPO=102
E_NO_DAYLOG=103
E_UNKNOWN_KERNEL=104

# Strings and filename constants
EXIT_MSG="Script terminated."
CONFIG_FILE="daylog.cfg"
CONFIG_PATH=~/'.config/daylog'
CONFIG_HERE=$CONFIG_PATH/$CONFIG_FILE

# Check for external config file
if [ ! -f $CONFIG_HERE ]; then
    echo -e "${YELLOW}Configuration file $CONFIG_FILE not found."
    echo -e "Using default configuration settings.${RESET}"
    # set default values
    # DO NOT enclose the tilde character ("~") in quotes (double or single)
    # as this prevents path expansion. To specify a directory name with
    # spaces, add the quotes AFTER the tidle, like this:
    # ~/'some path/with spaces/in it'
    repo_dir=~/'repos/writing/'
    daylog_dir=~/'repos/writing/daylogs/'
    EDITOR_APP="gvim"
else
    echo -e "${GREEN}Using configuration file:"
    echo -e $CONFIG_HERE "$RESET"
    source $CONFIG_HERE
fi

# Check for daylog directory
## Remove trailing slash
daylog_dir=${daylog_dir%/}
if [ ! -d $daylog_dir ]; then
    echo "Daylog directory not found:"
    echo $daylog_dir
    echo "$EXIT_MSG"
    exit $E_NO_REPO
fi

# Check for repository directory
## Remove trailing slash
repo_dir=${repo_dir%/}
if [ ! -d $repo_dir ]; then
    echo "Repository directory not found:"
    echo $repo_dir
    echo "$EXIT_MSG"
    exit $E_NO_DAYLOG
fi

# Before we make any changes to the local repo, pull updates
# Ensure we can enter the repo directory
cd "$repo_dir" || exit
echo "Working in repository:"
pwd
echo "Pulling the latest changes with rebase ..."
git pull --rebase
E_PULL=$?
# if it's not zero, there's a problem with the pull
if [ $E_PULL -ne 0 ]; then
    echo "Error pulling from repository."
    # TODO: ask to continue
    echo "$EXIT_MSG"
    exit $E_PULL
fi

# Strings: filename for today's daylog, full path, time stamp
DAYLOG_NAME="log-$(date +%Y-%m-%d).md"
PATH_TO_LOG="$daylog_dir/$DAYLOG_NAME"
TIME_STAMP="$(date +%H:%M)"

# does the file already exist?
if [ ! -f "$PATH_TO_LOG" ]; then
    doing_what="Create a new"
    add_lines=$(printf "# %s\n\n## %s" "$(date +%Y-%m-%d)" "$TIME_STAMP")
else
    doing_what="Edit existing"
    add_lines=$(printf "\n## %s" "$TIME_STAMP")
fi
echo "$doing_what daylog file, $DAYLOG_NAME"
echo "in directory: $daylog_dir;"
echo "then edit with $EDITOR_APP."

# Append an H2 timestamp to today's daylog file
echo "Appending time stamp to log file ..."
echo  "$add_lines"  >> "$PATH_TO_LOG"
# echo "$TIME_STAMP" >> "$PATH_TO_LOG"
echo "File updated, using $EDITOR_APP to edit log file:"
echo "$PATH_TO_LOG ..."

# Open today's daylog in the specified editor
# Store command result code or the script will continue
E_EDITED=$("$EDITOR_APP" "$PATH_TO_LOG")
# printf "Return value: %s\n" "$E_EDITED"


# the script resumes here after you quit the editor
WORD_COUNT=${BOLD}$(wc -w "$PATH_TO_LOG" | awk '{print $1}')
echo -e "${GREEN}Edits complete: $WORD_COUNT words saved.${RESET}"

# Detect platform and copy file to clipboard

KERNEL_NAME=$(uname)
echo "Kernel detected: $KERNEL_NAME"
echo "Copying $DAYLOG_NAME to system clipboard ..."
case $KERNEL_NAME in
    Linux*)
        xclip -selection clipboard -in "$PATH_TO_LOG"
        E_CLIP=$?
    ;;
    Darwin*)
        pbcopy < "$PATH_TO_LOG"
        E_CLIP=$?
    ;;
    *)
        E_CLIP=$E_UNKNOWN_KERNEL
        echo "Error $E_CLIP - Unknown or unsupported kernel, file not copied"
    ;;
esac

if [ $E_CLIP -eq 0 ]; then
    echo "Success! $DAYLOG_NAME copied to system clipboard."
fi

# stage and push to git
# TODO: git status check for changes
git add "$PATH_TO_LOG"
git_msg="Daily log file update by daylog.sh"
git commit -m "$git_msg"
git push

# if this all worked, there were no config errors
# TODO: A good time to save the config file
