#!/bin/bash

set -u

TARGET="${1:-}"

if [ -z "$TARGET" ]; then
echo "Usage: $0 <authorized-url>"
exit 1
fi

if ! [[ "$TARGET" =~ ^https?:// ]]; then
echo "Target must start with http:// or https://"
exit 1
fi

DOMAIN=$(echo "$TARGET" | sed -E 's#https?://##; s#/.*##')
REPORT="vuln_report_$(date +%Y%m%d_%H%M%S).txt"

PASS=0
WARN=0
FAIL=0

log() {
echo "$1" | tee -a "$REPORT"
}

check_pass() {
echo "[PASS] $1" | tee -a "$REPORT"
((PASS++))
}

check_warn() {
echo "[WARN] $1" | tee -a "$REPORT"
((WARN++))
}

check_fail() {
echo "[FAIL] $1" | tee -a "$REPORT"
((FAIL++))
}

echo "========================================" | tee "$REPORT"
echo "        WEB VULNERABILITY SCANNER" | tee -a "$REPORT"
echo "========================================" | tee -a "$REPORT"
echo "Target : $TARGET" | tee -a "$REPORT"
echo "Date   : $(date)" | tee -a "$REPORT"
echo | tee -a "$REPORT"

# ------------------------------------------------

# 1. Connectivity

# ------------------------------------------------

log "[1] CONNECTIVITY"
log "----------------------------------------"

STATUS=$(curl -L -s -o /dev/null 
-w "%{http_code}" 
--connect-timeout 5 
--max-time 15 
"$TARGET")

if [[ "$STATUS" =~ ^[23][0-9][0-9]$ ]]; then
check_pass "Website reachable - HTTP $STATUS"
else
check_warn "Website returned HTTP $STATUS"
fi

echo | tee -a "$REPORT"

# ------------------------------------------------

# 2. HTTPS

# ------------------------------------------------

log "[2] HTTPS"
log "----------------------------------------"

if [[ "$TARGET" == https://* ]]; then
check_pass "HTTPS is enabled"
else
check_fail "Target is not using HTTPS"
fi

echo | tee -a "$REPORT"

# ------------------------------------------------

# 3. Security Headers

# ------------------------------------------------

log "[3] SECURITY HEADERS"
log "----------------------------------------"

HEADERS=$(curl -LsI 
--connect-timeout 5 
--max-time 15 
"$TARGET" 2>/dev/null)

declare -A SECURITY_HEADERS=(
["Strict-Transport-Security"]="HSTS"
["Content-Security-Policy"]="CSP"
["X-Content-Type-Options"]="X-Content-Type-Options"
["X-Frame-Options"]="X-Frame-Options"
["Referrer-Policy"]="Referrer-Policy"
)

for header in "${!SECURITY_HEADERS[@]}"
do
if echo "$HEADERS" | grep -qi "^$header:"; then
check_pass "${SECURITY_HEADERS[$header]} present"
else
check_warn "${SECURITY_HEADERS[$header]} missing"
fi
done

echo | tee -a "$REPORT"

# ------------------------------------------------

# 4. Server Disclosure

# ------------------------------------------------

log "[4] SERVER INFORMATION"
log "----------------------------------------"

SERVER=$(echo "$HEADERS" |
grep -i "^server:" |
head -1)

if [ -n "$SERVER" ]; then
log "$SERVER"
check_warn "Server information is exposed"
else
check_pass "Server header not exposed"
fi

echo | tee -a "$REPORT"

# ------------------------------------------------

# 5. Dangerous HTTP Methods

# ------------------------------------------------

log "[5] HTTP METHODS"
log "----------------------------------------"

OPTIONS=$(curl -s -X OPTIONS 
-I 
--connect-timeout 5 
--max-time 10 
"$TARGET" 2>/dev/null)

ALLOW=$(echo "$OPTIONS" |
grep -i "^allow:" |
head -1)

if [ -n "$ALLOW" ]; then
log "$ALLOW"

```
if echo "$ALLOW" | grep -qiE "TRACE|DELETE|PUT"; then
    check_warn "Potentially sensitive HTTP methods advertised"
else
    check_pass "No obvious dangerous methods advertised"
fi
```

else
check_pass "No Allow header exposed"
fi

echo | tee -a "$REPORT"

# ------------------------------------------------

# 6. Cookie Security

# ------------------------------------------------

log "[6] COOKIE SECURITY"
log "----------------------------------------"

COOKIES=$(curl -LsI 
--connect-timeout 5 
--max-time 10 
"$TARGET" 2>/dev/null |
grep -i "^set-cookie:")

if [ -z "$COOKIES" ]; then
check_pass "No cookies detected"
else
echo "$COOKIES" | while read -r cookie
do
echo "Cookie: $cookie" >> "$REPORT"

```
    if echo "$cookie" | grep -qi "Secure"; then
        echo "[PASS] Cookie has Secure flag" >> "$REPORT"
    else
        echo "[WARN] Cookie missing Secure flag" >> "$REPORT"
    fi

    if echo "$cookie" | grep -qi "HttpOnly"; then
        echo "[PASS] Cookie has HttpOnly flag" >> "$REPORT"
    else
        echo "[WARN] Cookie missing HttpOnly flag" >> "$REPORT"
    fi

    if echo "$cookie" | grep -qi "SameSite"; then
        echo "[PASS] Cookie has SameSite attribute" >> "$REPORT"
    else
        echo "[WARN] Cookie missing SameSite attribute" >> "$REPORT"
    fi
done
```

fi

echo | tee -a "$REPORT"

# ------------------------------------------------

# 7. Common Exposed Files

# ------------------------------------------------

log "[7] COMMON EXPOSED FILES"
log "----------------------------------------"

PATHS=(
"/robots.txt"
"/sitemap.xml"
"/.git/HEAD"
"/.env"
"/backup.zip"
"/config.php"
)

for path in "${PATHS[@]}"
do
CODE=$(curl -Ls -o /dev/null 
-w "%{http_code}" 
--connect-timeout 3 
--max-time 8 
"$TARGET$path")

```
case "$path" in
    "/.git/HEAD"|"/.env"|"/backup.zip"|"/config.php")
        if [[ "$CODE" =~ ^2[0-9][0-9]$ ]]; then
            check_fail "Potentially sensitive resource accessible: $path (HTTP $CODE)"
        else
            check_pass "$path not accessible (HTTP $CODE)"
        fi
        ;;

    *)
        log "$path -> HTTP $CODE"
        ;;
esac
```

done

echo | tee -a "$REPORT"

# ------------------------------------------------

# 8. TLS Certificate

# ------------------------------------------------

log "[8] TLS CERTIFICATE"
log "----------------------------------------"

if [[ "$TARGET" == https://* ]]; then

```
CERT=$(echo | timeout 8 openssl s_client \
    -servername "$DOMAIN" \
    -connect "$DOMAIN:443" 2>/dev/null |
    openssl x509 -noout -dates 2>/dev/null)

if [ -n "$CERT" ]; then
    log "$CERT"

    EXPIRY=$(echo "$CERT" |
        grep "notAfter" |
        cut -d= -f2)

    if [ -n "$EXPIRY" ]; then
        EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s 2>/dev/null || echo 0)
        NOW=$(date +%s)
        DAYS=$(( (EXPIRY_EPOCH - NOW) / 86400 ))

        if [ "$DAYS" -lt 0 ]; then
            check_fail "TLS certificate has expired"
        elif [ "$DAYS" -lt 30 ]; then
            check_warn "TLS certificate expires in $DAYS days"
        else
            check_pass "TLS certificate valid for approximately $DAYS days"
        fi
    fi
else
    check_warn "Could not retrieve TLS certificate"
fi
```

else
check_warn "TLS check skipped because HTTPS is not enabled"
fi

echo | tee -a "$REPORT"

# ------------------------------------------------

# Final Summary

# ------------------------------------------------

log "========================================"
log "              SCAN SUMMARY"
log "========================================"

log "PASS : $PASS"
log "WARN : $WARN"
log "FAIL : $FAIL"

log
log "Report saved to: $REPORT"
log "========================================"
