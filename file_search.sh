#!/bin/bash

read -p "Enter the directory to search in: " directory
read -p "Enter the file name: " filename

if [ ! -d "$directory" ]; then
    echo "Directory does not exist."
    exit 1
fi

echo "Searching for $filename..."

find "$directory" -name "$filename"
