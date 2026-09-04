#!/bin/bash

read -p "Enter domain: " domain

if [ -z "$domain" ]; then
    echo "Domain cannot be empty."
    exit 1
fi

echo
echo "Finding subdomains for $domain..."
echo

subfinder -d "$domain"
