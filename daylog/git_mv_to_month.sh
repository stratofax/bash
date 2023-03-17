#!/usr/bin/env bash
# Move files to directories of years and months

TARGET_DIR=$1

if [ ! -d "$TARGET_DIR" ]; then
    echo "Target directory not found:"
    echo "$TARGET_DIR"
    echo "Script terminated."
    exit 1
fi

# Move files to directories of years and months
for year in {2021..2023}; do
    for month in {01..12}; do
        file_pattern="$TARGET_DIR/log-$year-$month"
        for file in "$file_pattern"*.md; do
            # ls "$TARGET_DIR$year/$month/$file"
            [ -f "$file" ] || continue
            echo "Moving $file to $TARGET_DIR/$year/$month/ ..."
            git mv "$file" "$TARGET_DIR"/"$year"/"$month"/
            echo "File moved."
        done
        # git mv "log-{$year}-{$month}-*" "$TARGET_DIR"/"$year"/"$month"
    done
done
