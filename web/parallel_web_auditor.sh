#!/bin/bash

set -u

TARGET_FILE="${1:-targets.txt}"
OUTPUT_DIR="web_audit_$(date +%Y%m%d_%H%M%S)"
MAX_JOBS=5
RETRIES=3
TIMEOUT=15

if [ ! -f "$TARGET_FILE" ]; then
echo "Target file not found: $TARGET_FILE"
echo "Usage: $0 targets.txt"
exit 1
fi

mkdir -p "$OUTPUT_DIR"

REPORT="$OUTPUT_DIR/report.csv"

echo "Target,IP,HTTP_Status,Response_Time,Final_URL,TLS_Expiry,HSTS,CSP,X_Frame_Options,X_Content_Type_Options,Status" > "$REPORT"

cleanup() {
wait
rm -rf "$OUTPUT_DIR/tmp"
}

trap cleanup EXIT

mkdir -p "$OUTPUT_DIR/tmp"

check_target() {
local target="$1"
local id="$2"

```
local safe_name
safe_name=$(echo "$target" | sed 's#[^a-zA-Z0-9]#_#g')

local result="$OUTPUT_DIR/tmp/${id}_${safe_name}.txt"

local domain
domain=$(echo "$target" | sed -E 's#https?://##; s#/.*##')

local ip="N/A"
local status="000"
local response_time="N/A"
local final_url="N/A"
local tls_expiry="N/A"
local hsts="MISSING"
local csp="MISSING"
local xframe="MISSING"
local xcontent="MISSING"
local overall="DOWN"

# -----------------------------
# DNS
# -----------------------------

ip=$(getent ahostsv4 "$domain" 2>/dev/null |
     awk '{print $1}' |
     sort -u |
     head -1)

[ -z "$ip" ] && ip="N/A"

# -----------------------------
# HTTP request with retry
# -----------------------------

local attempt=1

while [ "$attempt" -le "$RETRIES" ]
do
    response=$(curl -L -s \
        -o /dev/null \
        -w "%{http_code}|%{time_total}|%{url_effective}" \
        --connect-timeout 5 \
        --max-time "$TIMEOUT" \
        "$target" 2>/dev/null)

    status=$(echo "$response" | cut -d'|' -f1)
    response_time=$(echo "$response" | cut -d'|' -f2)
    final_url=$(echo "$response" | cut -d'|' -f3)

    if [ "$status" != "000" ]; then
        break
    fi

    sleep 1
    ((attempt++))
done

# -----------------------------
# Headers
# -----------------------------

headers=$(curl -L -sI \
    --connect-timeout 5 \
    --max-time "$TIMEOUT" \
    "$target" 2>/dev/null)

echo "$headers" | grep -qi "^strict-transport-security:" &&
    hsts="FOUND"

echo "$headers" | grep -qi "^content-security-policy:" &&
    csp="FOUND"

echo "$headers" | grep -qi "^x-frame-options:" &&
    xframe="FOUND"

echo "$headers" | grep -qi "^x-content-type-options:" &&
    xcontent="FOUND"

# -----------------------------
# TLS certificate
# -----------------------------

if [[ "$target" == https://* ]]; then

    cert=$(echo | timeout 8 openssl s_client \
        -servername "$domain" \
        -connect "$domain:443" 2>/dev/null |
        openssl x509 -noout -enddate 2>/dev/null)

    if [ -n "$cert" ]; then
        tls_expiry="${cert#*=}"
    fi
fi

# -----------------------------
# Overall status
# -----------------------------

if [[ "$status" =~ ^[23][0-9][0-9]$ ]]; then
    overall="UP"
elif [[ "$status" =~ ^[45][0-9][0-9]$ ]]; then
    overall="HTTP_ERROR"
fi

# -----------------------------
# Save result
# -----------------------------

{
    echo "Target       : $target"
    echo "IP           : $ip"
    echo "HTTP Status  : $status"
    echo "Response Time: ${response_time}s"
    echo "Final URL    : $final_url"
    echo "TLS Expiry   : $tls_expiry"
    echo "HSTS         : $hsts"
    echo "CSP          : $csp"
    echo "X-Frame      : $xframe"
    echo "X-Content    : $xcontent"
    echo "Status       : $overall"
} > "$result"

# -----------------------------
# CSV-safe output
# -----------------------------

printf '"%s","%s","%s","%s","%s","%s","%s","%s","%s","%s","%s"\n' \
    "$target" \
    "$ip" \
    "$status" \
    "$response_time" \
    "$final_url" \
    "$tls_expiry" \
    "$hsts" \
    "$csp" \
    "$xframe" \
    "$xcontent" \
    "$overall" >> "$REPORT"

echo "[+] $target -> $overall ($status)"
```

}

# ==========================================

# Parallel execution controller

# ==========================================

echo "=========================================="
echo "       PARALLEL WEB AUDITOR"
echo "=========================================="
echo
echo "Targets : $TARGET_FILE"
echo "Workers : $MAX_JOBS"
echo "Retries : $RETRIES"
echo

job_count=0
id=0

while IFS= read -r target || [ -n "$target" ]
do
# Ignore empty lines and comments
[[ -z "$target" ]] && continue
[[ "$target" =~ ^# ]] && continue

```
((id++))

check_target "$target" "$id" &

((job_count++))

if [ "$job_count" -ge "$MAX_JOBS" ]; then
    wait -n
    ((job_count--))
fi
```

done < "$TARGET_FILE"

wait

echo
echo "=========================================="
echo "             AUDIT COMPLETE"
echo "=========================================="
echo
echo "CSV Report:"
echo "$REPORT"
echo
echo "Individual results:"
echo "$OUTPUT_DIR/tmp/"
echo
echo "Targets processed: $id"
echo
echo "=========================================="
