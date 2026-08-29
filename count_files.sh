#!/bin/bash

read -p "Enter directory: " directory

if [ ! -d "$directory" ]; then
echo "Directory not found."
exit 1
fi

count=$(find "$directory" -type f | wc -l)

echo "Number of files: $count"
