```bash
#!/bin/bash

# Wi-Fi Network Scanner

if ! command -v nmcli >/dev/null 2>&1; then
    echo "Error: nmcli is not installed."
    exit 1
fi

REPORT="wifi_scan_$(date +%Y%m%d_%H%M%S).txt"

echo "==================================" | tee "$REPORT"
echo "       WI-FI NETWORK SCANNER" | tee -a "$REPORT"
echo "==================================" | tee -a "$REPORT"

echo "Date: $(date)" | tee -a "$REPORT"
echo "" | tee -a "$REPORT"

echo "[*] Scanning nearby Wi-Fi networks..."

nmcli --fields SSID,SECURITY,SIGNAL,CHAN \
    device wifi list --rescan yes |
    tee -a "$REPORT"

echo "" | tee -a "$REPORT"
echo "Scan completed." | tee -a "$REPORT"
echo "Report saved: $REPORT" | tee -a "$REPORT"
```
