```bash
#!/bin/bash

# Secure File Permission Auditor
# Identifies potentially risky file permissions.

set -u

TARGET="${1:-.}"

if [ ! -d "$TARGET" ]; then
    echo "Error: Directory does not exist."
    exit 1
fi

echo "========================================"
echo "       PERMISSION SECURITY AUDIT"
echo "========================================"
echo "Target: $TARGET"
echo

echo "[1] World-writable files"
echo "----------------------------------------"

find "$TARGET" -type f -perm -0002 -print 2>/dev/null

echo
echo "[2] SUID files"
echo "----------------------------------------"

find "$TARGET" -type f -perm -4000 -print 2>/dev/null

echo
echo "[3] SGID files"
echo "----------------------------------------"

find "$TARGET" -type f -perm -2000 -print 2>/dev/null

echo
echo "[4] World-writable directories"
echo "----------------------------------------"

find "$TARGET" -type d -perm -0002 -print 2>/dev/null

echo
echo "========================================"
echo "       AUDIT COMPLETED"
echo "========================================"
```
