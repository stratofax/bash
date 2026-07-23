#!/bin/bash

# --- Configuration ---
# Set the nameserver.
# If this is empty or commented out, the script will use the system's default nameservers.
nameserver="" # Example for using default public nameservers

# add specific nameservers here
# nameserver="ns-396.awsdns-49.com" # Example specific nameserver
nameserver="lina.ns.cloudflare.com"

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

# --- Script Logic ---

if [ -n "$nameserver" ]; then
    echo "Using specific nameserver: $nameserver"
else
    echo "Using system's default (public) nameservers."
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

    # Execute the dig command
    if [ -n "$nameserver" ]; then
        # If nameserver is set, use it
        dig @"$nameserver" "$subdomain" "$type_name" +noall +answer
    else
        # If nameserver is not set (empty), omit it to use default DNS
        dig "$subdomain" "$type_name" +noall +answer
    fi
    
    # Add a separator for readability between lookups
    echo "-------------------------------------"
done

echo "Script finished."
