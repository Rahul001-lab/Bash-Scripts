#!/bin/bash

set -u

TARGET="${1:-.}"

if [ ! -d "$TARGET" ]; then
    echo "Error: Directory does not exist."
    exit 1
fi

echo "================================"
echo "       FILE TYPE REPORT"
echo "================================"
echo "Directory: $TARGET"
echo

find "$TARGET" -type f -print0 | while IFS= read -r -d '' FILE; do
    file -b "$FILE"
done | sort | uniq -c | sort -nr

echo
echo "================================"
echo "Report completed."
echo "================================"
