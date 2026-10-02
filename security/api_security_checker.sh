```bash
#!/bin/bash

# API Security Checker
# Use only against APIs you own or are authorized to assess.

set -u

TARGET="${1:-}"

if [ -z "$TARGET" ]; then
    echo "Usage: $0 <authorized-api-url>"
    echo "Example: $0 https://example.com/api"
    exit 1
fi

if ! [[ "$TARGET" =~ ^https?:// ]]; then
    echo "Error: URL must start with http:// or https://"
    exit 1
fi

REPORT="api_audit_$(date +%Y%m%d_%H%M%S).txt"

PASS=0
WARN=0
INFO=0

log() {
    echo "$1" | tee -a "$REPORT"
}

pass() {
    echo "[PASS] $1" | tee -a "$REPORT"
    ((PASS++))
}

warn() {
    echo "[WARN] $1" | tee -a "$REPORT"
    ((WARN++))
}

info() {
    echo "[INFO] $1" | tee -a "$REPORT"
    ((INFO++))
}

echo "============================================" | tee "$REPORT"
echo "           API SECURITY CHECKER" | tee -a "$REPORT"
echo "============================================" | tee -a "$REPORT"
log "Target : $TARGET"
log "Date   : $(date)"
log ""

# ------------------------------------------------
# 1. Basic connectivity
# ------------------------------------------------

log "[1] CONNECTIVITY"

STATUS=$(curl -Ls \
    -o /dev/null \
    -w "%{http_code}" \
    --connect-timeout 5 \
    --max-time 15 \
    "$TARGET" 2>/dev/null)

TIME=$(curl -Ls \
    -o /dev/null \
    -w "%{time_total}" \
    --connect-timeout 5 \
    --max-time 15 \
    "$TARGET" 2>/dev/null)

if [[ "$STATUS" =~ ^[23][0-9][0-9]$ ]]; then
    pass "API reachable - HTTP $STATUS"
else
    warn "API returned HTTP $STATUS"
fi

info "Response time: ${TIME}s"

log ""

# ------------------------------------------------
# 2. HTTPS check
# ------------------------------------------------

log "[2] HTTPS"

if [[ "$TARGET" == https://* ]]; then
    pass "HTTPS enabled"
else
    warn "API is not using HTTPS"
fi

log ""

# ------------------------------------------------
# 3. Response headers
# ------------------------------------------------

log "[3] RESPONSE HEADERS"

HEADERS=$(curl -sIL \
    --connect-timeout 5 \
    --max-time 15 \
    "$TARGET" 2>/dev/null)

if [ -z "$HEADERS" ]; then
    warn "Could not retrieve response headers"
else
    echo "$HEADERS" >> "$REPORT"

    CONTENT_TYPE=$(echo "$HEADERS" |
        grep -i "^content-type:" |
        tail -1)

    SERVER=$(echo "$HEADERS" |
        grep -i "^server:" |
        tail -1)

    if echo "$CONTENT_TYPE" | grep -qi "application/json"; then
        pass "API returns JSON content type"
    elif [ -n "$CONTENT_TYPE" ]; then
        info "$CONTENT_TYPE"
    else
        warn "Content-Type header not detected"
    fi

    if [ -n "$SERVER" ]; then
        warn "Server information exposed: $SERVER"
    else
        pass "Server header not exposed"
    fi
fi

log ""

# ------------------------------------------------
# 4. Security headers
# ------------------------------------------------

log "[4] SECURITY HEADERS"

declare -A SECURITY_HEADERS=(
    ["X-Content-Type-Options"]="X-Content-Type-Options"
    ["Content-Security-Policy"]="Content-Security-Policy"
    ["Strict-Transport-Security"]="Strict-Transport-Security"
    ["Referrer-Policy"]="Referrer-Policy"
)

for HEADER in "${!SECURITY_HEADERS[@]}"
do
    if echo "$HEADERS" | grep -qi "^$HEADER:"; then
        pass "${SECURITY_HEADERS[$HEADER]} present"
    else
        warn "${SECURITY_HEADERS[$HEADER]} missing"
    fi
done

log ""

# ------------------------------------------------
# 5. CORS
# ------------------------------------------------

log "[5] CORS"

CORS=$(curl -sI \
    -H "Origin: https://example-test.invalid" \
    --connect-timeout 5 \
    --max-time 10 \
    "$TARGET" 2>/dev/null |
    grep -i "^access-control-allow-origin:")

if [ -z "$CORS" ]; then
    info "No Access-Control-Allow-Origin header detected"
else
    log "$CORS"

    if echo "$CORS" | grep -q "\*"; then
        warn "Wildcard CORS policy detected"
    else
        info "Specific CORS origin detected"
    fi
fi

log ""

# ------------------------------------------------
# 6. HTTP methods
# ------------------------------------------------

log "[6] HTTP METHODS"

OPTIONS=$(curl -sI \
    -X OPTIONS \
    --connect-timeout 5 \
    --max-time 10 \
    "$TARGET" 2>/dev/null)

ALLOW=$(echo "$OPTIONS" |
    grep -i "^allow:" |
    head -1)

if [ -n "$ALLOW" ]; then
    log "$ALLOW"

    if echo "$ALLOW" | grep -qi "TRACE"; then
        warn "TRACE method advertised"
    else
        pass "TRACE method not advertised"
    fi

    if echo "$ALLOW" | grep -qiE "PUT|DELETE|PATCH"; then
        info "State-changing methods are advertised"
    fi
else
    info "Allow header not returned"
fi

log ""

# ------------------------------------------------
# 7. OPTIONS response
# ------------------------------------------------

log "[7] OPTIONS REQUEST"

OPTIONS_STATUS=$(curl -s \
    -o /dev/null \
    -w "%{http_code}" \
    -X OPTIONS \
    --connect-timeout 5 \
    --max-time 10 \
    "$TARGET" 2>/dev/null)

info "OPTIONS response: HTTP $OPTIONS_STATUS"

log ""

# ------------------------------------------------
# 8. Redirect detection
# ------------------------------------------------

log "[8] REDIRECTS"

REDIRECTS=$(curl -sIL \
    --max-time 15 \
    "$TARGET" 2>/dev/null |
    grep -i "^location:")

if [ -n "$REDIRECTS" ]; then
    info "Redirect chain detected:"
    echo "$REDIRECTS" | tee -a "$REPORT"
else
    pass "No redirect chain detected"
fi

log ""

# ------------------------------------------------
# 9. Cookie security
# ------------------------------------------------

log "[9] COOKIES"

COOKIES=$(curl -sIL \
    --connect-timeout 5 \
    --max-time 10 \
    "$TARGET" 2>/dev/null |
    grep -i "^set-cookie:")

if [ -z "$COOKIES" ]; then
    info "No cookies detected"
else
    while read -r COOKIE
    do
        log "$COOKIE"

        if echo "$COOKIE" | grep -qi "Secure"; then
            pass "Cookie has Secure flag"
        else
            warn "Cookie missing Secure flag"
        fi

        if echo "$COOKIE" | grep -qi "HttpOnly"; then
            pass "Cookie has HttpOnly flag"
        else
            warn "Cookie missing HttpOnly flag"
        fi

        if echo "$COOKIE" | grep -qi "SameSite"; then
            pass "Cookie has SameSite attribute"
        else
            warn "Cookie missing SameSite attribute"
        fi

    done <<< "$COOKIES"
fi

log ""

# ------------------------------------------------
# 10. Common API documentation endpoints
# ------------------------------------------------

log "[10] API DOCUMENTATION CHECK"

DOC_PATHS=(
    "/swagger"
    "/swagger-ui"
    "/swagger-ui/"
    "/api-docs"
    "/openapi.json"
    "/swagger.json"
)

BASE=$(echo "$TARGET" | sed 's#/$##')

for PATH in "${DOC_PATHS[@]}"
do
    CODE=$(curl -Ls \
        -o /dev/null \
        -w "%{http_code}" \
        --connect-timeout 3 \
        --max-time 8 \
        "$BASE$PATH" 2>/dev/null)

    if [[ "$CODE" =~ ^2[0-9][0-9]$ ]]; then
        info "Documentation endpoint accessible: $PATH (HTTP $CODE)"
    fi
done

log ""

# ------------------------------------------------
# 11. Common sensitive API files
# ------------------------------------------------

log "[11] SENSITIVE RESOURCE CHECK"

SENSITIVE_PATHS=(
    "/.env"
    "/.git/HEAD"
    "/config.json"
    "/config.php"
    "/backup.zip"
)

for PATH in "${SENSITIVE_PATHS[@]}"
do
    CODE=$(curl -Ls \
        -o /dev/null \
        -w "%{http_code}" \
        --connect-timeout 3 \
        --max-time 8 \
        "$BASE$PATH" 2>/dev/null)

    if [[ "$CODE" =~ ^2[0-9][0-9]$ ]]; then
        warn "Potentially sensitive resource accessible: $PATH (HTTP $CODE)"
    else
        pass "$PATH not accessible (HTTP $CODE)"
    fi
done

log ""

# ------------------------------------------------
# 12. TLS certificate
# ------------------------------------------------

log "[12] TLS CERTIFICATE"

if [[ "$TARGET" == https://* ]]; then

    DOMAIN=$(echo "$TARGET" |
        sed -E 's#https://##; s#/.*##')

    CERT=$(echo |
        timeout 8 openssl s_client \
        -servername "$DOMAIN" \
        -connect "$DOMAIN:443" 2>/dev/null |
        openssl x509 -noout -dates 2>/dev/null)

    if [ -n "$CERT" ]; then
        echo "$CERT" | tee -a "$REPORT"

        EXPIRY=$(echo "$CERT" |
            grep "notAfter" |
            cut -d= -f2)

        EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s 2>/dev/null || echo 0)
        NOW=$(date +%s)

        DAYS=$(( (EXPIRY_EPOCH - NOW) / 86400 ))

        if [ "$DAYS" -lt 0 ]; then
            warn "TLS certificate has expired"
        elif [ "$DAYS" -lt 30 ]; then
            warn "TLS certificate expires in $DAYS days"
        else
            pass "TLS certificate valid for approximately $DAYS days"
        fi
    else
        warn "Could not retrieve TLS certificate"
    fi
else
    info "TLS certificate check skipped"
fi

log ""

# ------------------------------------------------
# 13. Final summary
# ------------------------------------------------

log "============================================"
log "                 SUMMARY"
log "============================================"

log "PASS : $PASS"
log "WARN : $WARN"
log "INFO : $INFO"

log ""
log "Report saved to:"
log "$REPORT"

log "============================================"
```

