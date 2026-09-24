#!/bin/bash

read -p "Enter website URL: " url

if [ -z "$url" ]; then
echo "URL cannot be empty."
exit 1
fi

echo
echo "================================="
echo "          WEB INFORMATION"
echo "================================="

echo
echo "[+] HTTP Status"
curl -L -s -o /dev/null -w "%{http_code}\n" "$url"

echo
echo "[+] Response Time"
curl -L -s -o /dev/null -w "%{time_total}s\n" "$url"

echo
echo "[+] Server Information"
curl -sI "$url" | grep -Ei "^server:|^content-type:|^content-length:"

echo
echo "[+] Redirect Information"
curl -Ls -o /dev/null -w "Final URL: %{url_effective}\n" "$url"

echo
echo "[+] HTTPS Check"
if [[ "$url" == https://* ]]; then
echo "HTTPS: Enabled"
else
echo "HTTPS: Not used"
fi

echo
echo "[+] Page Title"
curl -Ls "$url" 2>/dev/null |
grep -oi '<title[^>]*>[^<]*' |
head -1 |
sed 's/<[^>]*>//g'

echo
echo "[+] HTTP Headers"
curl -sI "$url"

echo
echo "================================="
echo "        CHECK COMPLETE"
echo "================================="
