#!/bin/bash

read -p "Enter log file path: " logfile

if [ ! -f "$logfile" ]; then
echo "Log file not found."
exit 1
fi

echo "================================="
echo "         LOG ANALYZER"
echo "================================="
echo

echo "[+] Total Lines"
wc -l < "$logfile"

echo
echo "[+] Errors"
grep -i "error" "$logfile" | wc -l

echo
echo "[+] Warnings"
grep -i "warning" "$logfile" | wc -l

echo
echo "[+] Failed Login Attempts"
grep -i "failed" "$logfile" | wc -l

echo
echo "[+] Successful Login Attempts"
grep -Ei "success|accepted" "$logfile" | wc -l

echo
echo "[+] Last 10 Log Entries"
tail -n 10 "$logfile"

echo
echo "================================="
echo "        ANALYSIS COMPLETE"
echo "================================="
