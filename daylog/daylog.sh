#!/bin/bash
# creates a file in the specified directory
# and opens it with your favorite editor
# shellcheck disable=SC2034  # Unused variables left for readability

# turn on unoffical bash strict mode
set -euo pipefail
IFS=$'\n\t'

# what script is running?
basename "$0"
#######################################
# Set up constants
#######################################
SCRIPT_PATH=$(dirname "$0")
# shellcheck source=/dev/null # source the colors.sh file
source "${SCRIPT_PATH}"/../lib/colors.sh

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
    color_echo "${YELLOW}" "Configuration file not found:"
    color_echo "${B_YELLOW}" "${CONFIG_FILE}"
    color_echo "${YELLOW}" "Using default configuration settings."
    # set default values
    # DO NOT enclose the tilde character ("~") in quotes (double or single)
    # as this prevents path expansion. To specify a directory name with
    # spaces, add the quotes AFTER the tidle, like this:
    # ~/'some path/with spaces/in it'
    repo_dir=~/'repos/writing/'
    daylog_dir=~/'repos/writing/daylogs/'
    editor_app="gvim"
else
    color_echo "${GREEN}" "Using configuration file:"
    color_echo "${B_GREEN}" "$CONFIG_HERE"
    # shellcheck source=/dev/null # source the configuration file
    source $CONFIG_HERE
fi

# Check for daylog directory
## Remove trailing slash
daylog_dir=${daylog_dir%/}
if [ ! -d "$daylog_dir" ]; then
    echo "Daylog directory not found:"
    echo "$daylog_dir"
    echo "$EXIT_MSG"
    exit $E_NO_REPO
fi

# Check for repository directory
## Remove trailing slash
repo_dir=${repo_dir%/}
if [ ! -d "$repo_dir" ]; then
    echo "Repository directory not found:"
    echo "$repo_dir"
    echo "$EXIT_MSG"
    exit $E_NO_DAYLOG
fi

# Before we make any changes to the local repo, pull updates
# Ensure we can enter the repo directory
cd "$repo_dir" || exit
echo "Working in repository:"
color_echo "${GREEN}" "$(pwd)"
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
YEAR=$(date +%Y)
MONTH=$(date +%m)
TODAYS_DIR="$daylog_dir/$YEAR/$MONTH"

if [ ! -d "$TODAYS_DIR" ]; then
    echo "Creating directory for today's daylog:"
    echo "$TODAYS_DIR"
    mkdir -p "$TODAYS_DIR"
fi

DAYLOG_NAME="log-$(date +%Y-%m-%d).md"
PATH_TO_LOG="$TODAYS_DIR/$DAYLOG_NAME"
TIME_STAMP="$(date +%H:%M)"

# does the file already exist?
if [ ! -f "$PATH_TO_LOG" ]; then
    doing_what="Create a new"
    add_lines=$(printf "# %s\n\n## %s" "$(date +%Y-%m-%d)" "$TIME_STAMP")
else
    doing_what="Update existing"
    add_lines=$(printf "\n## %s" "$TIME_STAMP")
fi
echo -e "${doing_what} daylog file, ${CYAN}${DAYLOG_NAME}${RESET}"
echo "in directory: ${TODAYS_DIR};"
echo "then edit with ${editor_app}."

# Append an H2 timestamp to today's daylog file
echo "Appending time stamp to log file ..."
echo  "$add_lines"  >> "$PATH_TO_LOG"
echo "File updated, using $editor_app to edit log file:"
color_echo "${CYAN}" "${PATH_TO_LOG} ..."

# Open today's daylog in the specified editor
# Store command result code or the script will continue
# if the editor_app is vim or nvim, 
# replace with GUI default
if [ "$editor_app" = "vim" ] || [ "$editor_app" = "nvim" ]; then
  editor_app="gvim"
fi
E_EDITED=$("$editor_app" "$PATH_TO_LOG")
# printf "Return value: %s\n" "$E_EDITED"

# the script resumes here after you quit the editor
WORD_COUNT=${BOLD}$(wc -w "$PATH_TO_LOG" | awk '{print $1}')
color_echo "${GREEN}" "Edits complete: $WORD_COUNT words saved."

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
    echo -e "${GREEN}Success! $DAYLOG_NAME copied to system clipboard.${RESET}"
fi

# stage and push to git
# TODO: git status check for changes
git add "$PATH_TO_LOG"
git_msg="Daily log file update by daylog.sh"
git commit -m "$git_msg"
git push

# if this all worked, there were no config errors
# TODO: A good time to save the config file
