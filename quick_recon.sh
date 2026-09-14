#!/bin/bash

echo "================================="
echo "        QUICK RECON"
echo "================================="
echo

echo "[+] Hostname"
hostname

echo
echo "[+] Current User"
whoami

echo
echo "[+] Operating System"
grep PRETTY_NAME /etc/os-release

echo
echo "[+] Local IP"
hostname -I

echo
echo "[+] Default Gateway"
ip route | grep default

echo
echo "[+] DNS Servers"
grep "nameserver" /etc/resolv.conf

echo
echo "[+] Listening Ports"
ss -tuln

echo
echo "[+] System Uptime"
uptime -p

echo
echo "================================="
echo "        RECON COMPLETE"
echo "================================="
