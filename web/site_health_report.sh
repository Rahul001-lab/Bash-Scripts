#!/bin/bash

read -p "Enter website URL: " url

if [ -z "$url" ]; then
echo "URL cannot be empty."
exit 1
fi

domain=$(echo "$url" | sed -E 's#https?://##; s#/.*##')
report="site_report_$(date +%Y%m%d_%H%M%S).txt"

{
echo "=========================================="
echo "          WEBSITE HEALTH REPORT"
echo "=========================================="
echo "Target: $url"
echo "Date  : $(date)"
echo

echo "[1] DNS RESOLUTION"
echo "------------------------------------------"
getent ahosts "$domain" | awk '{print $1}' | sort -u

echo
echo "[2] HTTP STATUS & RESPONSE TIME"
echo "------------------------------------------"
curl -L -s -o /dev/null 
-w "Status       : %{http_code}\nResponse time: %{time_total}s\n" 
--max-time 15 "$url"

echo
echo "[3] FINAL URL"
echo "------------------------------------------"
curl -L -s -o /dev/null 
-w "%{url_effective}\n" 
--max-time 15 "$url"

echo
echo "[4] SECURITY HEADERS"
echo "------------------------------------------"

headers=$(curl -LsI --max-time 15 "$url")

for header in 
"strict-transport-security" 
"content-security-policy" 
"x-frame-options" 
"x-content-type-options" 
"referrer-policy"
do
if echo "$headers" | grep -qi "^$header:"; then
echo "[FOUND] $header"
else
echo "[MISSING] $header"
fi
done

echo
echo "[5] TLS CERTIFICATE"
echo "------------------------------------------"

if [[ "$url" == https://* ]]; then
expiry=$(echo | openssl s_client 
-servername "$domain" 
-connect "$domain:443" 2>/dev/null |
openssl x509 -noout -enddate 2>/dev/null)

```
if [ -n "$expiry" ]; then
    echo "$expiry"
else
    echo "Could not retrieve certificate."
fi
```

else
echo "HTTPS is not being used."
fi

echo
echo "[6] ROBOTS.TXT"
echo "------------------------------------------"

robots=$(curl -Ls --max-time 10 "https://$domain/robots.txt")

if [ -n "$robots" ]; then
echo "$robots" | head -20
else
echo "robots.txt not found or unavailable."
fi

echo
echo "[7] SITEMAP"
echo "------------------------------------------"

status=$(curl -Ls -o /dev/null -w "%{http_code}" 
--max-time 10 "https://$domain/sitemap.xml")

if [ "$status" = "200" ]; then
echo "sitemap.xml found."
else
echo "sitemap.xml not found. HTTP $status"
fi

echo
echo "[8] SERVER INFORMATION"
echo "------------------------------------------"

echo "$headers" | grep -Ei 
"^server:|^content-type:|^content-length:"

echo
echo "=========================================="
echo "          REPORT COMPLETE"
echo "=========================================="

} | tee "$report"

echo
echo "[+] Report saved to: $report"
