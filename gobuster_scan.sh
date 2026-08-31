#!/bin/bash

read -p "Enter target URL: " target
read -p "Enter wordlist path: " wordlist

if [ -z "$target" ] || [ -z "$wordlist" ]; then
echo "Target and wordlist are required."
exit 1
fi

if [ ! -f "$wordlist" ]; then
echo "Wordlist not found."
exit 1
fi

echo
echo "Starting Gobuster scan..."
echo "Target: $target"
echo

gobuster dir -u "$target" -w "$wordlist"
