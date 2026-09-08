#!/bin/bash

read -p "Enter file path: " file

if [ ! -f "$file" ]; then
echo "File not found."
exit 1
fi

backup="${file}.backup_$(date +%Y%m%d_%H%M%S)"

cp "$file" "$backup"

echo "Backup created successfully."
echo "Saved as: $backup"
