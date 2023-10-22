#!/usr/bin/env bash
# daylog_cfg.sh
# creates a configuration file
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
# Add color constants and color_echo function
source "${SCRIPT_PATH}"/../colors.sh

# Strings and filename constants
CONFIG_FILE="daylog.cfg"
CONFIG_PATH=~/'.config/daylog'
CONFIG_HERE=$CONFIG_PATH/$CONFIG_FILE

#######################################
# Functions
#######################################

function print_line( ) {
    color_echo "${WHITE}" "-------------------------------------------------------"
}

# review the editor, ask for changes
function check_editor( ) {
    # check to see if we can locate the editor
    if which "${editor_app}" >/dev/null; then
        color_echo "${WHITE}" "Current editor:"
        color_echo "${B_YELLOW}" "${editor_app}"
        color_echo "${WHITE}" "Do you want to change the editor?"
        color_echo "${WHITE}" "Enter the name of the editor you want to use."
        color_echo "${WHITE}" "Or press Enter to keep the current editor."
        read -r "new_editor_app"
        if [ -z "$new_editor_app" ]; then
            color_echo "${B_WHITE}" "Keeping the current editor:"
            color_echo "${B_YELLOW}" "${editor_app}"
            print_line
        else
            editor_app="$new_editor_app"
            check_editor
        fi
    else
        color_echo "${B_RED}" "The editor was not found:"
        color_echo "${B_YELLOW}" "${editor_app}"
        color_echo "${B_CYAN}" "Please enter a new editor (CTRL-C to quit):"
        read -r editor_app
        check_editor
    fi
}

# check to see if the directory exists
function check_dir( ) {
    dir_name=$1
    description=$2
    dir_help=$3
    if [ ! -d "$dir_name" ]; then
        color_echo "${WHITE}" "The ${B_WHITE}${description}${WHITE} directory is:"
        color_echo "${WHITE}" "${dir_help}"
        print_line
        color_echo "${B_RED}" "The $description directory was not found:"
        color_echo "${B_YELLOW}" "${dir_name}"
        print_line
        color_echo "${B_CYAN}" "Please enter a new $description directory (CTRL-C to quit):"
        read -r dir_name
        check_dir "$dir_name" "$description" "$dir_help"
    else
        color_echo "${WHITE}" "Current $description directory:"
        color_echo "${B_YELLOW}" "${dir_name}"
        color_echo "${WHITE}" "Do you want to change the $description directory?"
        color_echo "${WHITE}" "Enter the name of the directory you want to use."
        color_echo "${WHITE}" "Or press Enter to keep the current directory."
        read -r new_dir_name
        # if the input is empty, keep the current directory
        if [ -z "$new_dir_name" ]; then
            color_echo "${B_WHITE}" "Keeping the current $description directory:"
            color_echo "${B_YELLOW}" "${dir_name}"
            print_line
        else
            dir_name=$new_dir_name
            color_echo "${B_WHITE}" "Using the new $description directory:"
            color_echo "${B_YELLOW}" "${dir_name}"
            print_line
            check_dir "$dir_name" "$description" "$dir_help"
        fi
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
else
    color_echo "${WHITE}" "Configuration file found:"
    color_echo "${B_YELLOW}" "${CONFIG_HERE}"
    # load the configuration file
    # shellcheck source=/dev/null # source the configuration file
    source $CONFIG_HERE
fi
# DO NOT enclose the tilde character ("~") in quotes (double or single)
# as this prevents path expansion. To specify a directory name with
# spaces, add the quotes AFTER the tidle, like this:
# ~/'some path/with spaces/in it'
# set default values if the configuration file is not set
if [[ -z ${repo_dir+x} ]]; then repo_dir=~/'repos/writing/'; fi
# repo_dir=~/'nothing/here/'
if [[ -z ${daylog_dir+x} ]]; then daylog_dir=~/'repos/writing/daylogs/'; fi
# editor_app="novim"
if [[ -z ${editor_app+x} ]]; then editor_app="gvim"; fi

# review the current configuration, ask for changes
color_echo "${B_WHITE}" "Current daylog configuration"
print_line

# review the repository directory
check_dir "$repo_dir" "repository" "the root of the repository that contains your daylogs"
check_dir "$daylog_dir" "daylog" "The specific directory that contains your daylogs"
check_editor

# display a message: writing the configuration file
# use the color_echo function from colors.sh
color_echo "${WHITE}" "Writing the configuration file"
color_echo "${WHITE}" "to the configuration directory:"
color_echo "${B_YELLOW}" "${CONFIG_PATH}"

# if the configuration directory does not exist, create it and the configuration file
if [ ! -d $CONFIG_PATH ]; then
    mkdir -p $CONFIG_PATH
    touch $CONFIG_HERE
fi

# if the configuration file exists, overwrite it
if [ -f $CONFIG_HERE ]; then
    rm $CONFIG_HERE
    touch $CONFIG_HERE
fi

# write the configuration file
short_machine_name=$(hostname -s)
date_stamp=$(date +%Y-%m-%d)
eval "echo \"# daylog configuration file for ${short_machine_name}\" >> $CONFIG_HERE"
eval "echo \"# created on ${date_stamp}\" >> $CONFIG_HERE"
eval "echo \"repo_dir='$repo_dir'\" >> $CONFIG_HERE"
eval "echo \"daylog_dir='$daylog_dir'\" >> $CONFIG_HERE"
eval "echo \"editor_app='$editor_app'\" >> $CONFIG_HERE"
color_echo "${B_WHITE}" "Configuration file written:" 
color_echo "${B_YELLOW}" "${CONFIG_HERE}"
print_line
cat $CONFIG_HERE
print_line
