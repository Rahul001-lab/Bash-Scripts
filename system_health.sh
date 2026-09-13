#!/bin/bash

echo "===== SYSTEM HEALTH ====="
echo

echo "Hostname: $(hostname)"
echo "Uptime: $(uptime -p)"
echo "CPU Cores: $(nproc)"
echo "Memory:"
free -h | awk '/Mem:/ {print "  Used:", $3, "/", $2}'

echo
echo "Disk:"
df -h / | awk 'NR==2 {print "  Used:", $3, "/", $2, "("$5")"}'

echo
echo "Top 5 Processes:"
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -6
