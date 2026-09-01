#!/bin/bash

read -p "Enter domain: " domain
read -p "Enter wordlist path: " wordlist

if [ -z "$domain" ] || [ -z "$wordlist" ]; then
    echo "Domain and wordlist are required."
    exit 1
fi

if [ ! -f "$wordlist" ]; then
    echo "Wordlist not found."
    exit 1
fi

echo
echo "Starting DNS enumeration..."
echo "Target: $domain"
echo

gobuster dns -d "$domain" -w "$wordlist"
