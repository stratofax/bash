#!/bin/bash
# update a list of servers over ssh

# turn on unoffical bash strict mode
set -euo pipefail
IFS=$'\n\t'

LIST_FILE="server_list.csv"
SERVER_LIST=''

# read a list of servers from a file
# if the file does not exist, create it
if [ ! -f "$LIST_FILE" ]; then
    echo "Server list file not found: $LIST_FILE"
    touch $LIST_FILE
    echo "Server list file created: $LIST_FILE"
else
    echo "Server list file found: $LIST_FILE"
    $SERVER_LIST < "$LIST_FILE"
    echo "$SERVER_LIST"
fi

while true; do
    echo "Select an option:"
    echo "1. Update servers listed"
    echo "2. Add a new server"
    echo "3. Exit"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            echo "Updating servers..."
            # Add your code here for continuing
            break
            ;;
        2)
            echo "Adding a new server..."
            # Add your code here for adding a new server
            ;;
        3)
            echo "Exiting..."
            # Add your code here for exiting
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done

