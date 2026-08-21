#!/bin/bash

echo "=================================="
echo "       SYSTEM INFORMATION"
echo "=================================="

echo "Hostname      : $(hostname)"
echo "Operating Sys : $(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')"
echo "Kernel        : $(uname -r)"
echo "Architecture  : $(uname -m)"
echo "Uptime        : $(uptime -p)"
echo "CPU           : $(nproc) cores"
echo "Memory        : $(free -h | awk '/Mem:/ {print $3 " / " $2}')"
echo "Disk Usage    : $(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"

echo "=================================="
