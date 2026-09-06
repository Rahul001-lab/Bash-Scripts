#!/bin/bash

read -p "Enter password length: " length

if ! [[ "$length" =~ ^[0-9]+$ ]] || [ "$length" -lt 4 ]; then
echo "Enter a number greater than or equal to 4."
exit 1
fi

password=$(tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c "$length")

echo
echo "Generated Password:"
echo "$password"
