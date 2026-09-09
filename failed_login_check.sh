#!/bin/bash

LOG="/var/log/auth.log"

if [ ! -f "$LOG" ]; then
echo "Authentication log not found."
exit 1
fi

count=$(grep -c "Failed password" "$LOG")

echo "Failed SSH login attempts: $count"
