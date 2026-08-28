#!/bin/bash

read -p "Enter the folder path to back up: " folder

if [ ! -d "$folder" ]; then
echo "Error: Folder does not exist."
exit 1
fi

backup_name="backup_$(date +%Y-%m-%d_%H-%M-%S).tar.gz"

tar -czf "$backup_name" "$folder"

echo "Backup created successfully: $backup_name"
