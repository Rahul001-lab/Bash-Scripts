```bash
#!/bin/bash

# Subdomain Monitor
# Use only against domains you own or are authorized to monitor.

set -u

DOMAIN="${1:-}"
WORDLIST="${2:-}"

if [ -z "$DOMAIN" ] || [ -z "$WORDLIST" ]; then
    echo "Usage: $0 <authorized-domain> <wordlist>"
    echo "Example: $0 example.com subdomains.txt"
    exit 1
fi

if [ ! -f "$WORDLIST" ]; then
    echo "Wordlist not found: $WORDLIST"
    exit 1
fi

BASE_DIR="subdomain_monitor"
SNAPSHOT_DIR="$BASE_DIR/snapshots"
CURRENT="$SNAPSHOT_DIR/current.txt"
PREVIOUS="$SNAPSHOT_DIR/previous.txt"
REPORT="$BASE_DIR/report_$(date +%Y%m%d_%H%M%S).txt"

mkdir -p "$SNAPSHOT_DIR"

echo "============================================" | tee "$REPORT"
echo "         SUBDOMAIN CHANGE MONITOR" | tee -a "$REPORT"
echo "============================================" | tee -a "$REPORT"
echo "Domain : $DOMAIN" | tee -a "$REPORT"
echo "Date   : $(date)" | tee -a "$REPORT"
echo | tee -a "$REPORT"

# Preserve previous snapshot
if [ -f "$CURRENT" ]; then
    cp "$CURRENT" "$PREVIOUS"
fi

: > "$CURRENT"

TMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$TMP_DIR"
}

trap cleanup EXIT

echo "[*] Checking subdomains..." | tee -a "$REPORT"

check_subdomain() {

    SUB="$1"
    HOST="${SUB}.${DOMAIN}"

    IP=$(getent ahostsv4 "$HOST" 2>/dev/null |
        awk 'NR==1 {print $1}')

    if [ -z "$IP" ]; then
        return
    fi

    URL="https://${HOST}"

    STATUS=$(curl -k -Ls \
        -o /dev/null \
        -w "%{http_code}" \
        --connect-timeout 3 \
        --max-time 8 \
        "$URL" 2>/dev/null)

    if [ "$STATUS" = "000" ]; then

        URL="http://${HOST}"

        STATUS=$(curl -Ls \
            -o /dev/null \
            -w "%{http_code}" \
            --connect-timeout 3 \
            --max-time 8 \
            "$URL" 2>/dev/null)
    fi

    echo "${HOST}|${IP}|${STATUS}" >> "$TMP_DIR/results"
}

export DOMAIN TMP_DIR
export -f check_subdomain

# Parallel enumeration
grep -vE '^[[:space:]]*$|^[[:space:]]*#' "$WORDLIST" |
    sort -u |
    xargs -P 10 -I {} bash -c 'check_subdomain "$1"' _ {}

if [ -f "$TMP_DIR/results" ]; then
    sort -u "$TMP_DIR/results" > "$CURRENT"
fi

COUNT=$(wc -l < "$CURRENT")

echo "[+] Active/resolving subdomains: $COUNT" | tee -a "$REPORT"
echo | tee -a "$REPORT"

# ------------------------------------------------
# Current results
# ------------------------------------------------

echo "[CURRENT SUBDOMAINS]" | tee -a "$REPORT"

if [ -s "$CURRENT" ]; then

    while IFS='|' read -r HOST IP STATUS
    do
        printf "%-35s %-16s HTTP %-5s\n" \
            "$HOST" "$IP" "$STATUS" |
            tee -a "$REPORT"
    done < "$CURRENT"

else
    echo "No resolving subdomains found." | tee -a "$REPORT"
fi

echo | tee -a "$REPORT"

# ------------------------------------------------
# Compare snapshots
# ------------------------------------------------

if [ -f "$PREVIOUS" ]; then

    echo "[CHANGES]" | tee -a "$REPORT"

    NEW=$(comm -13 \
        <(cut -d'|' -f1 "$PREVIOUS" | sort) \
        <(cut -d'|' -f1 "$CURRENT" | sort))

    REMOVED=$(comm -23 \
        <(cut -d'|' -f1 "$PREVIOUS" | sort) \
        <(cut -d'|' -f1 "$CURRENT" | sort))

    if [ -n "$NEW" ]; then
        echo "[NEW HOSTS]" | tee -a "$REPORT"

        while read -r HOST
        do
            echo "+ $HOST" | tee -a "$REPORT"
        done <<< "$NEW"
    else
        echo "No new subdomains detected." | tee -a "$REPORT"
    fi

    echo | tee -a "$REPORT"

    if [ -n "$REMOVED" ]; then
        echo "[REMOVED HOSTS]" | tee -a "$REPORT"

        while read -r HOST
        do
            echo "- $HOST" | tee -a "$REPORT"
        done <<< "$REMOVED"
    else
        echo "No removed subdomains detected." | tee -a "$REPORT"
    fi

    echo | tee -a "$REPORT"

    # Detect IP changes
    echo "[IP CHANGES]" | tee -a "$REPORT"

    while IFS='|' read -r HOST IP STATUS
    do

        OLD_IP=$(grep "^${HOST}|" "$PREVIOUS" 2>/dev/null |
            cut -d'|' -f2)

        if [ -n "$OLD_IP" ] && [ "$OLD_IP" != "$IP" ]; then
            echo "$HOST : $OLD_IP -> $IP" |
                tee -a "$REPORT"
        fi

    done < "$CURRENT"

else

    echo "No previous snapshot found." | tee -a "$REPORT"
    echo "This scan becomes the baseline." | tee -a "$REPORT"

fi

echo | tee -a "$REPORT"

# ------------------------------------------------
# HTTP status changes
# ------------------------------------------------

if [ -f "$PREVIOUS" ]; then

    echo "[HTTP STATUS CHANGES]" | tee -a "$REPORT"

    while IFS='|' read -r HOST IP STATUS
    do

        OLD_STATUS=$(grep "^${HOST}|" "$PREVIOUS" 2>/dev/null |
            cut -d'|' -f3)

        if [ -n "$OLD_STATUS" ] &&
           [ "$OLD_STATUS" != "$STATUS" ]; then

            echo "$HOST : HTTP $OLD_STATUS -> HTTP $STATUS" |
                tee -a "$REPORT"

        fi

    done < "$CURRENT"

fi

echo | tee -a "$REPORT"

# ------------------------------------------------
# Summary
# ------------------------------------------------

echo "============================================" | tee -a "$REPORT"
echo "                  SUMMARY" | tee -a "$REPORT"
echo "============================================" | tee -a "$REPORT"

echo "Domain       : $DOMAIN" | tee -a "$REPORT"
echo "Subdomains   : $COUNT" | tee -a "$REPORT"
echo "Snapshot     : $CURRENT" | tee -a "$REPORT"
echo "Report       : $REPORT" | tee -a "$REPORT"

echo "============================================" | tee -a "$REPORT"
```
