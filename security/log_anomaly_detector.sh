#!/bin/bash

read -p "Enter log file: " logfile
read -p "Alert threshold (number of entries): " threshold

if [ ! -f "$logfile" ]; then
echo "Log file not found."
exit 1
fi

if ! [[ "$threshold" =~ ^[0-9]+$ ]]; then
echo "Threshold must be a number."
exit 1
fi

echo
echo "========================================"
echo "        LOG ANOMALY DETECTOR"
echo "========================================"
echo

echo "[+] Total log entries:"
wc -l < "$logfile"

echo
echo "[+] Most active IP addresses:"
echo "----------------------------------------"

grep -Eo '([0-9]{1,3}.){3}[0-9]{1,3}' "$logfile" |
sort |
uniq -c |
sort -nr |
head -10

echo
echo "[+] IPs above threshold: $threshold"
echo "----------------------------------------"

grep -Eo '([0-9]{1,3}.){3}[0-9]{1,3}' "$logfile" |
sort |
uniq -c |
sort -nr |
awk -v limit="$threshold" '$1 >= limit {
printf "ALERT: %-16s %s entries\n", $2, $1
}'

echo
echo "[+] Common error messages:"
echo "----------------------------------------"

grep -iE "error|failed|denied|invalid" "$logfile" |
head -10

echo
echo "========================================"
echo "          ANALYSIS COMPLETE"
echo "========================================"
