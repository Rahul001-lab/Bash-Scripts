#!/bin/bash

SNAPSHOT="$HOME/.system_snapshot.txt"
CURRENT="/tmp/current_system_snapshot.txt"

echo "================================="
echo "      SYSTEM CHANGE DETECTOR"
echo "================================="
echo

echo "[+] Collecting system information..."

{
echo "===== HOST ====="
hostname

```
echo "===== OS ====="
grep "^PRETTY_NAME=" /etc/os-release

echo "===== KERNEL ====="
uname -r

echo "===== USERS ====="
cut -d: -f1 /etc/passwd

echo "===== LISTENING PORTS ====="
ss -tuln

echo "===== NETWORK ====="
ip -br addr

echo "===== ROUTES ====="
ip route

echo "===== INSTALLED PACKAGES ====="
if command -v dpkg >/dev/null 2>&1; then
    dpkg-query -W -f='${Package}\n' 2>/dev/null
fi

echo "===== SERVICES ====="
systemctl list-unit-files --type=service --state=enabled 2>/dev/null
```

} > "$CURRENT"

if [ ! -f "$SNAPSHOT" ]; then
cp "$CURRENT" "$SNAPSHOT"

```
echo
echo "[+] First snapshot created."
echo "[+] Saved to: $SNAPSHOT"
exit 0
```

fi

echo
echo "[+] Comparing with previous snapshot..."
echo

if diff -u "$SNAPSHOT" "$CURRENT" > /tmp/system_changes.txt; then
echo "[+] No changes detected."
else
echo "[!] SYSTEM CHANGES DETECTED!"
echo
cat /tmp/system_changes.txt

```
cp "$CURRENT" "$SNAPSHOT"

echo
echo "[+] Snapshot updated."
```

fi

rm -f "$CURRENT" /tmp/system_changes.txt

echo
echo "================================="
echo "           CHECK COMPLETE"
echo "================================="
