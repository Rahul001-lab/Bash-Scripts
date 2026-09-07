#!/bin/bash

read -p "Enter process name: " process

if [ -z "$process" ]; then
echo "Process name cannot be empty."
exit 1
fi

if pgrep -x "$process" > /dev/null; then
echo "Process '$process' is running."
else
echo "Process '$process' is not running."
fi
