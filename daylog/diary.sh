#!/bin/bash
# creates a file in the specified directory
# and opens it with your favorite editor
# shellcheck disable=SC2034  # Unused variables left for readability

# turn on unoffical bash strict mode
set -euo pipefail
IFS=$'\n\t'

# Source colors early to make them available for all messages
SCRIPT_PATH=$(dirname "$0")
# shellcheck source=/dev/null # source the colors.sh file
source "${SCRIPT_PATH}"/../lib/colors.sh

#######################################
# Help and Usage Functions
#######################################
show_help() {
    local script_name
    script_name=$(basename "$0")
    
    color_echo "${B_GREEN}" "Diary - A simple command-line diary application"
    echo "Usage: $script_name [options]"
    echo
    echo "Options:"
    echo "  -h, --help       Show this help message and exit"
    echo "  -c, --config     Show current configuration and exit"
    echo "  -v, --version    Show version information and exit"
    echo "  -n, --new        Force creation of a new diary entry"
    echo "  -e, --editor CMD Use CMD as the editor (overrides config)"
    echo
    echo "If no options are provided, opens today's diary entry in the configured editor."
    exit 0
}

show_version() {
    echo "diary.sh - v1.0.0"
    echo "A simple command-line diary application"
    exit 0
}

show_config() {
    echo "Current Configuration:"
    echo "  Repository: ${repo_dir:-Not set}"
    echo "  Diary Dir:  ${diary_dir:-Not set}"
    echo "  Editor:     ${editor_app:-Not set}"
    echo "  Config:     ${CONFIG_HERE:-Not set}"
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            ;;
        -v|--version)
            show_version
            ;;
        -c|--config)
            show_config
            ;;
        -e|--editor)
            if [[ -n "${2:-}" ]]; then
                editor_override="$2"
                shift
            else
                color_echo "${RED}" "Error: --editor requires an argument"
                exit 1
            fi
            ;;
        -n|--new)
            force_new=true
            ;;
        --no-pull)
            skip_pull=true
            ;;
        *)
            color_echo "${YELLOW}" "Warning: Unknown option '$1'"
            show_help
            ;;
    esac
    shift
done

# what script is running?
basename "$0"
#######################################
# Set up constants
#######################################

# Error codes
E_NO_REPO=102
E_NO_DIARY=103
E_NO_EDITOR=104

# Strings and filename constants
EXIT_MSG="Script terminated."
CONFIG_FILE="diary.cfg"
CONFIG_PATH=~/'.config/diary'
CONFIG_HERE=$CONFIG_PATH/$CONFIG_FILE

# Apply editor override if specified via command line
if [[ -n "${editor_override:-}" ]]; then
    editor_app="$editor_override"
    color_echo "${BLUE}" "Using editor from command line: $editor_app"
    # Skip editor validation since we trust the user's input
    skip_editor_validation=true
fi

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
    repo_dir=~/'Repos/stratofax/slipbox/'
    diary_dir=~/'Repos/stratofax/slipbox/diary/'
    editor_app="windsurf"
else
    color_echo "${GREEN}" "Using configuration file:"
    color_echo "${B_GREEN}" "$CONFIG_HERE"
    # shellcheck source=/dev/null # source the configuration file
    if ! source "$CONFIG_HERE"; then
        color_echo "${RED}" "Error: Failed to load configuration from $CONFIG_HERE"
        exit 1
    fi
    
    # Validate required configuration variables
    local missing_vars=()
    local var
    for var in repo_dir diary_dir editor_app; do
        if [[ -z "${!var:-}" ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        color_echo "${RED}" "Error: Missing required configuration in $CONFIG_HERE"
        color_echo "${YELLOW}" "The following variables are missing or empty: ${missing_vars[*]}"
        exit 1
    fi
fi

# Clean and validate paths
repo_dir=${repo_dir%/}
diary_dir=${diary_dir%/}

# Check for diary directory
if [ ! -d "$diary_dir" ]; then
    echo "Diary directory not found:"
    echo "$diary_dir"
    echo "$EXIT_MSG"
    exit $E_NO_DIARY
fi

# Check if editor exists
validate_editor() {
    # Skip validation if flag is set
    [[ "${skip_editor_validation:-}" = true ]] && return 0
    
    local editor=$1
    if ! command -v "$editor" >/dev/null 2>&1; then
        color_echo "${RED}" "Error: Editor '$editor' not found in PATH"
        return 1
    fi
    return 0
}

# Check for repository directory
## Remove trailing slash
repo_dir=${repo_dir%/}
if [ ! -d "$repo_dir" ]; then
    echo "Repository directory not found:"
    echo "$repo_dir"
    echo "$EXIT_MSG"
    exit $E_NO_REPO
fi

# Before we make any changes to the local repo, pull updates if requested
if [[ "${skip_pull:-false}" != "true" ]]; then
    # Ensure we can enter the repo directory
    cd "$repo_dir" || exit
    echo "Working in repository:"
    color_echo "${GREEN}" "$(pwd)"
    
    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        color_echo "${YELLOW}" "Warning: You have uncommitted changes. Skipping git pull to prevent conflicts."
        color_echo "${YELLOW}" "Use '--no-pull' to suppress this warning in the future."
    else
        echo "Pulling the latest changes with rebase ..."
        if ! git pull --rebase; then
            color_echo "${YELLOW}" "Warning: Failed to pull latest changes. Continuing with local version."
            color_echo "${YELLOW}" "Use '--no-pull' to skip pulling in the future."
        fi
    fi
    
    # Return to the script directory
    cd - >/dev/null || exit
fi

# Strings: filename for today's diary, full path, time stamp
diary_name="$(date +%Y-%m-%d).md"
TIME_STAMP="$(date +%H:%M)"

path_to_diary="${diary_dir}/${diary_name}"


# does the file already exist?
if [ ! -f "$path_to_diary" ]; then
    doing_what="Create a new"
    add_lines=$(printf "# %s\n\n## %s" "$(date +%Y-%m-%d)" "$TIME_STAMP")
else
    doing_what="Update existing"
    add_lines=$(printf "\n## %s" "$TIME_STAMP")
fi
echo -e "${doing_what} diary file, ${CYAN}${diary_name}${RESET}"
echo "in directory:"
color_echo "${CYAN}" "${diary_dir}"
echo "then edit with ${editor_app}."

# Append an H2 timestamp to today's diary file
echo "Appending time stamp to log file ..."
echo  "$add_lines"  >> "$path_to_diary"
echo "File updated, using $editor_app to edit log file:"
color_echo "${CYAN}" "${path_to_diary} ..."

# Open today's diary in the specified editor
# First check if the editor exists
if ! validate_editor "$editor_app"; then
    # Try to find a fallback editor
    color_echo "${YELLOW}" "Trying to find a fallback editor..."
    for editor in "code" "nano" "vi" "vim" "nvim"; do
        if command -v "$editor" >/dev/null 2>&1; then
            editor_app="$editor"
            color_echo "${GREEN}" "Using fallback editor: $editor_app"
            break
        fi
    done
    
    # Final check if we found a valid editor
    if ! validate_editor "$editor_app"; then
        color_echo "${RED}" "Error: No suitable editor found. Please install one (e.g., code, nano, vim)"
        exit $E_NO_EDITOR
    fi
fi

# Function to open the editor
open_editor() {
    # Replace vim/nvim with gvim if available
    if [[ "$editor_app" =~ ^(vim|nvim)$ ]] && command -v "g${editor_app}" >/dev/null 2>&1; then
        editor_app="g${editor_app}"
        color_echo "${BLUE}" "Using GUI version: $editor_app"
    fi

    # Use the override editor if specified, otherwise use the configured one
    local editor_to_use="${editor_override:-$editor_app}"
    color_echo "${GREEN}" "Opening diary with $editor_to_use..."
    
    if ! "$editor_to_use" "$path_to_diary"; then
        color_echo "${YELLOW}" "Editor returned non-zero status. Your changes may not have been saved."
        return 1
    fi
    
    return 0
}

# Open the editor and handle the result
if open_editor; then
    color_echo "${GREEN}" "Diary entry saved to: $path_to_diary"
else
    exit 1
fi
