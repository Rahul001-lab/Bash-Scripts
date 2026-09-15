#!/bin/bash

read -p "Enter target URL: " target

if [ -z "$target" ]; then
echo "URL cannot be empty."
exit 1
fi

echo "================================="
echo "          WEB RECON"
echo "================================="
echo

echo "[+] Target"
echo "$target"

echo
echo "[+] HTTP Status"
curl -s -o /dev/null -w "%{http_code}\n" "$target"

echo
echo "[+] HTTP Headers"
curl -sI "$target"

echo
echo "[+] Page Title"
curl -Ls "$target" | grep -oi '<title>[^<]*' | head -1

echo
echo "[+] Technologies"
whatweb "$target"

echo
echo "[+] DNS Information"

domain=$(echo "$target" | sed -E 's#https?://##; s#/.*##')

nslookup "$domain"

echo
echo "================================="
echo "       RECON COMPLETE"
echo "================================="
