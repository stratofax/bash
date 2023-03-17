#!/usr/bin/env bash
# Create directories of years and months

TARGET_DIR=$1

if [ ! -d "$TARGET_DIR" ]; then
    echo "Target directory not found:"
    echo "$TARGET_DIR"
    echo "Script terminated."
    exit 1
fi

# Create directories of years and months
for year in {2020..2023}; do
    mkdir -p "$TARGET_DIR"/"$year"
    for month in {01..12}; do
        mkdir -p "$TARGET_DIR"/"$year"/"$month"
    done
done