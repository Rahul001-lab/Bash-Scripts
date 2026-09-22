#!/bin/bash

read -p "Enter URL list file: " file

if [ ! -f "$file" ]; then
echo "URL list not found."
exit 1
fi

echo "================================="
echo "       WEBSITE MONITOR"
echo "================================="
echo

while IFS= read -r url
do
# Skip empty lines
[ -z "$url" ] && continue

```
status=$(curl -L -s -o /dev/null -w "%{http_code}" --max-time 10 "$url")

if [[ "$status" =~ ^2|3 ]]; then
    echo "[UP]   $url  -> HTTP $status"
elif [ "$status" = "000" ]; then
    echo "[DOWN] $url  -> No response"
else
    echo "[WARN] $url  -> HTTP $status"
fi
```

done < "$file"

echo
echo "================================="
echo "         CHECK COMPLETE"
echo "================================="
