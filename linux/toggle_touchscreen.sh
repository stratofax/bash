#!/bin/bash

# --- Configuration ---
# Configuration file name
CONFIG_FILENAME="touchscreen_config.conf"
CONFIG_FILE="$(dirname "$0")/$CONFIG_FILENAME"

# Function to generate config file if it doesn't exist
generate_config_file() {
    echo "Touchscreen configuration file not found. Let's create one."
    echo "Searching for touch devices..."
    
    # Get all devices with "touch" in the name
    touch_devices=$(xinput list | grep -i "touch" | grep -v "XTEST")
    
    if [ -z "$touch_devices" ]; then
        echo "No touch devices found. Please check your hardware and try again."
        exit 1
    fi
    
    # Display devices with line numbers
    echo "Found the following potential touchscreen devices:"
    echo "$touch_devices" | nl -w2 -s') '
    
    # Get device selection from user
    echo ""
    read -p "Enter the number of your touchscreen device (not the ID): " selection
    
    # Validate selection
    max_selection=$(echo "$touch_devices" | wc -l)
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "$max_selection" ]; then
        echo "Invalid selection. Please run the script again and enter a valid number."
        exit 1
    fi
    
    # Get the selected device line
    selected_device=$(echo "$touch_devices" | sed -n "${selection}p")
    
    # Extract device ID and name
    device_id=$(echo "$selected_device" | grep -oP 'id=\K\d+')
    device_name=$(echo "$selected_device" | grep -oP '(?<=↳ ).*?(?=id=)' | sed 's/^[ \t]*//;s/[ \t]*$//')
    
    if [ -z "$device_id" ]; then
        echo "Could not extract device ID. Please run the script again."
        exit 1
    fi
    
    # Create config file
    echo "# Configuration for toggle_touchscreen.sh" > "$CONFIG_FILE"
    echo "# Created on $(date)" >> "$CONFIG_FILE"
    echo "# Selected device: $device_name" >> "$CONFIG_FILE"
    echo "TOUCHSCREEN_ID=$device_id" >> "$CONFIG_FILE"
    
    echo "Configuration file created at $CONFIG_FILE"
    echo "Touchscreen ID set to $device_id ($device_name)"
}

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    generate_config_file
fi

# Source the config file
source "$CONFIG_FILE"

# Verify that TOUCHSCREEN_ID is set
if [ -z "$TOUCHSCREEN_ID" ]; then
    echo "Error: TOUCHSCREEN_ID not set in config file"
    echo "Please edit $CONFIG_FILE and set TOUCHSCREEN_ID or delete it to regenerate"
    exit 1
fi

# --- Script Logic ---

# Get the current state of the touchscreen using its ID
DEVICE_ENABLED=$(xinput list-props $TOUCHSCREEN_ID | grep "Device Enabled" | awk '{print $NF}')

if [ -z "$DEVICE_ENABLED" ]; then
    echo "Error: Could not get properties for touchscreen device with ID $TOUCHSCREEN_ID."
    echo "Please verify the device ID from 'xinput list'."
    exit 1
fi

# Toggle the state
if [ "$DEVICE_ENABLED" -eq 1 ]; then
    # Device is enabled, disable it
    xinput disable $TOUCHSCREEN_ID
    echo "Touchscreen (ID: $TOUCHSCREEN_ID) disabled."
else
    # Device is disabled, enable it
    xinput enable $TOUCHSCREEN_ID
    echo "Touchscreen (ID: $TOUCHSCREEN_ID) enabled."
fi

exit 0