#!/bin/bash

read -p "Enter URL: " url

if [ -z "$url" ]; then
    echo "URL cannot be empty."
    exit 1
fi

echo
echo "Checking $url..."
echo

curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" "$url"
