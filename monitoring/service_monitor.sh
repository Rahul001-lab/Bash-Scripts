#!/bin/bash

read -p "Enter service name: " service

if [ -z "$service" ]; then
echo "Service name cannot be empty."
exit 1
fi

if ! systemctl list-unit-files | grep -q "^${service}.service"; then
echo "Service '$service' not found."
exit 1
fi

echo
echo "Checking $service..."

if systemctl is-active --quiet "$service"; then
echo "[+] $service is running."
else
echo "[-] $service is not running."
echo "[+] Attempting to restart $service..."

```
sudo systemctl restart "$service"

if systemctl is-active --quiet "$service"; then
    echo "[+] $service restarted successfully."
else
    echo "[-] Failed to restart $service."
    exit 1
fi
```

fi

echo
echo "[+] Service status:"
systemctl --no-pager status "$service" | head -10
