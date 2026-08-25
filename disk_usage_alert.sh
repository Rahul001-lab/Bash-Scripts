#!/bin/bash

# Disk Usage Alert Script
# Usage: ./disk_usage_alert.sh [threshold]

THRESHOLD=${1:-80}

echo "======================================"
echo "         DISK USAGE CHECK"
echo "======================================"
echo

# Validate threshold
if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]]; then
    echo "Error: Threshold must be a number."
    echo "Usage: $0 [threshold]"
    exit 1
fi

if [ "$THRESHOLD" -lt 1 ] || [ "$THRESHOLD" -gt 100 ]; then
    echo "Error: Threshold must be between 1 and 100."
    exit 1
fi

# Get disk usage information
df -P -x tmpfs -x devtmpfs | tail -n +2 | while read -r filesystem size used available percentage mountpoint
do
    # Remove % from usage value
    usage=${percentage%\%}

    echo "Filesystem : $filesystem"
    echo "Mount Point: $mountpoint"
    echo "Usage      : $percentage"

    if [ "$usage" -ge "$THRESHOLD" ]; then
        echo "WARNING: Disk usage is above the ${THRESHOLD}% threshold!"
    else
        echo "Status: OK"
    fi

    echo "--------------------------------------"
done
