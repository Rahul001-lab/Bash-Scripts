#!/bin/bash

ip=$(hostname -I | awk '{print $1}')

if [ -z "$ip" ]; then
echo "Could not find local IP address."
exit 1
fi

echo "Local IP Address: $ip"
