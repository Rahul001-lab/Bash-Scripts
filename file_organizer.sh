#!/bin/bash

# File Organizer
# Organizes files into folders based on their extensions

TARGET_DIR="$1"

if [ -z "$TARGET_DIR" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory does not exist."
    exit 1
fi
