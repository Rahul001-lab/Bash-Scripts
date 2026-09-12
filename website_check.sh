#!/bin/bash

read -p "Enter website URL: " url

if [ -z "$url" ]; then
echo "URL cannot be empty."
exit 1
fi

echo
echo "Checking $url..."
echo

curl -o /dev/null -s -w "Status: %{http_code}\nResponse Time: %{time_total}s\n" "$url"
