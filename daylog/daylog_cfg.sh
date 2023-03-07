#!/usr/bin/env bash
# daylog_config.sh creates a configuration file 
# in the configuration directory
# with the configuration variables you select

# turn on unoffical bash strict mode
set -euo pipefail
IFS=$'\n\t'

# what script is running?
basename "$0"
#######################################
# Set up constants
#######################################
SCRIPT_PATH=$(dirname "$0")
source "${SCRIPT_PATH}"/colors.sh

# Strings and filename constants
EXIT_MSG="Script terminated."
CONFIG_FILE="daylog.cfg"
CONFIG_PATH=~/'.config/daylog'
CONFIG_HERE=$CONFIG_PATH/$CONFIG_FILE

#######################################
# Functions
#######################################

function print_line( ) {
    color_echo "${B_WHITE}" "-------------------------------------------------------"
}

# check to see if the directory exists
function check_dir( ) { 
    dir_name=$1
    description=$2
    dir_help=$3
    if [ ! -d $dir_name ]; then
        color_echo "${B_WHITE}" "The ${description} directory is"
        color_echo "${B_WHITE}" "${dir_help}"
        print_line
        color_echo "${B_RED}" "The $description directory was not found:"
        color_echo "${B_YELLOW}" "${dir_name}"
        print_line
        color_echo "${B_CYAN}" "Please enter a new $description directory:"
        read -r dir_name
        check_dir $dir_name $description $dir_help
    else
        color_echo "${WHITE}" "Current $description directory:"
        color_echo "${B_YELLOW}" "${dir_name}"
        print_line
    fi
}

#######################################
# display a welcome message
# use the color_echo function from colors.sh

print_line
color_echo "${B_WHITE}" "Welcome to the daylog config tool"
print_line

# Check for external config file
if [ ! -f $CONFIG_HERE ]; then
    color_echo "${YELLOW}" "Configuration file not found:"
    color_echo "${B_YELLOW}" "${CONFIG_FILE}"
    color_echo "${CYAN}" "Using default configuration settings."
    print_line
    # DO NOT enclose the tilde character ("~") in quotes (double or single)
    # as this prevents path expansion. To specify a directory name with
    # spaces, add the quotes AFTER the tidle, like this:
    # ~/'some path/with spaces/in it'
    # set default values
    # repo_dir=~/'repos/writing/'
    repo_dir=~/'nothing/here/'
    daylog_dir=~/'repos/writing/daylogs/'
    EDITOR_APP="gvim"
else
    # load the configuration file
    source $config_here
fi

# review the current configuration, ask for changes
color_echo "${B_WHITE}" "Current configuration"

# review the repository directory
check_dir $repo_dir "repository" "the root of the repository that contains your daylogs"
check_dir $daylog_dir "daylog" "The specific directory that contains your daylogs"
