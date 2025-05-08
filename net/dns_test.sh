#!/bin/bash

# --- Configuration ---
# Set the nameserver.
# If this is empty or commented out, the script will use the system's default nameservers.
nameserver="" # Example for using default public nameservers

# add specific nameservers here
nameserver="ns-396.awsdns-49.com" # Example specific nameserver
# nameserver="lina.ns.cloudflare.com"

# Define the array of parameters.
# Each element is a string with "type_name,subdomain"
# You can add as many parameter sets as you need.
declare -a params=(
    "a,cadent.com"
    "mx,cadent.com"
    "cname,www.cadent.com"
    "txt,cadent.com"
    "txt,_dmarc.cadent.com"
    "txt,google._domainkey.cadent.com"
    # Add more parameters here, e.g., "soa,anotherdomain.net"
)

# --- Command Line Options ---
# Default to using dig
use_nslookup=false

# Parse command line options
while getopts "n" opt; do
    case $opt in
        n)
            use_nslookup=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            echo "Usage: $0 [-n]" >&2
            echo "  -n  Use nslookup instead of dig" >&2
            exit 1
            ;;
    esac
done

# --- Script Logic ---

if [ -n "$nameserver" ]; then
    echo "Using specific nameserver: $nameserver"
else
    echo "Using system's default (public) nameservers."
fi

if $use_nslookup; then
    echo "Using nslookup command"
else
    echo "Using dig command"
fi
echo "-------------------------------------"

# Loop through the array of parameters
for param_set in "${params[@]}"; do
    # Split the parameter set string by the comma delimiter
    IFS=',' read -r type_name subdomain <<< "$param_set"

    # Check if both type_name and subdomain were successfully read
    if [ -z "$type_name" ] || [ -z "$subdomain" ]; then
        echo "Warning: Skipping invalid parameter set: '$param_set'. Ensure format is 'type,subdomain'."
        echo "-------------------------------------"
        continue
    fi

    echo "Querying type: $type_name for subdomain: $subdomain"

    # Execute the appropriate command based on the use_nslookup flag
    if $use_nslookup; then
        # Using nslookup
        if [ -n "$nameserver" ]; then
            # If nameserver is set, use it
            nslookup -timeout=2 -type="$type_name" "$subdomain" "$nameserver"
        else
            # If nameserver is not set (empty), omit it to use default DNS
            nslookup -timeout=2 -type="$type_name" "$subdomain"
        fi
    else
        # Using dig
        if [ -n "$nameserver" ]; then
            # If nameserver is set, use it
            dig @"$nameserver" "$subdomain" "$type_name" +noall +answer
        else
            # If nameserver is not set (empty), omit it to use default DNS
            dig "$subdomain" "$type_name" +noall +answer
        fi
    fi
    
    # Add a separator for readability between lookups
    echo "-------------------------------------"
done

echo "Script finished."
