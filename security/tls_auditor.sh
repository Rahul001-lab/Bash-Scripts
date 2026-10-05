```bash
#!/bin/bash

# Authorized API Endpoint Mapper
# Maps known API paths, methods, status codes, content types,
# response sizes, and response times.

set -u

BASE_URL="${1:-}"
WORDLIST="${2:-}"

if [ -z "$BASE_URL" ] || [ -z "$WORDLIST" ]; then
    echo "Usage: $0 <authorized-api-url> <wordlist>"
    exit 1
fi

if ! [[ "$BASE_URL" =~ ^https?:// ]]; then
    echo "Error: URL must start with http:// or https://"
    exit 1
fi

if [ ! -f "$WORDLIST" ]; then
    echo "Error: Wordlist not found"
    exit 1
fi

BASE_URL="${BASE_URL%/}"
REPORT="api_map_$(date +%Y%m%d_%H%M%S).txt"
RESULTS="api_results_$(date +%Y%m%d_%H%M%S).csv"

TOTAL=0
FOUND=0

echo "============================================" | tee "$REPORT"
echo "           API ENDPOINT MAPPER" | tee -a "$REPORT"
echo "============================================" | tee -a "$REPORT"
echo "Target: $BASE_URL" | tee -a "$REPORT"
echo "Date  : $(date)" | tee -a "$REPORT"
echo | tee -a "$REPORT"

echo "PATH,STATUS,METHOD,CONTENT_TYPE,SIZE,TIME" > "$RESULTS"

check_endpoint() {

    PATH="$1"
    URL="${BASE_URL}/${PATH#/}"

    RESPONSE_HEADERS=$(mktemp)
    RESPONSE_BODY=$(mktemp)

    STATUS=$(curl -ks \
        -D "$RESPONSE_HEADERS" \
        -o "$RESPONSE_BODY" \
        -w "%{http_code}" \
        --connect-timeout 4 \
        --max-time 10 \
        "$URL" 2>/dev/null)

    SIZE=$(wc -c < "$RESPONSE_BODY")

    TIME=$(curl -ks \
        -o /dev/null \
        -w "%{time_total}" \
        --connect-timeout 4 \
        --max-time 10 \
        "$URL" 2>/dev/null)

    CONTENT_TYPE=$(grep -i "^content-type:" "$RESPONSE_HEADERS" |
        head -1 |
        sed 's/\r//' |
        cut -d: -f2- |
        xargs)

    if [ "$STATUS" != "404" ] && [ "$STATUS" != "000" ]; then
        echo "$PATH,$STATUS,GET,\"$CONTENT_TYPE\",$SIZE,$TIME" >> "$RESULTS"
    fi

    rm -f "$RESPONSE_HEADERS" "$RESPONSE_BODY"
}

export BASE_URL RESULTS
export -f check_endpoint

echo "[*] Mapping endpoints..." | tee -a "$REPORT"

grep -vE '^[[:space:]]*$|^[[:space:]]*#' "$WORDLIST" |
    sed 's#^/##' |
    sort -u |
    while read -r PATH
    do
        ((TOTAL++))
        check_endpoint "$PATH"
    done

if [ -f "$RESULTS" ]; then
    FOUND=$(tail -n +2 "$RESULTS" | wc -l)
fi

echo | tee -a "$REPORT"
echo "[DISCOVERED ENDPOINTS]" | tee -a "$REPORT"

if [ "$FOUND" -gt 0 ]; then

    column -t -s ',' "$RESULTS" | tee -a "$REPORT"

else

    echo "No endpoints discovered." | tee -a "$REPORT"

fi

echo | tee -a "$REPORT"
echo "[STATUS BREAKDOWN]" | tee -a "$REPORT"

for CODE in 200 201 204 301 302 400 401 403 405 500
do
    COUNT=$(tail -n +2 "$RESULTS" 2>/dev/null |
        awk -F',' -v code="$CODE" '$2 == code {count++} END {print count+0}')

    if [ "$COUNT" -gt 0 ]; then
        echo "HTTP $CODE : $COUNT" | tee -a "$REPORT"
    fi
done

echo | tee -a "$REPORT"
echo "[POTENTIALLY INTERESTING ENDPOINTS]" | tee -a "$REPORT"

grep -Ei \
    'admin|login|auth|user|account|config|debug|internal|private|upload|backup|token|key|swagger|docs|api' \
    "$RESULTS" 2>/dev/null |
    tee -a "$REPORT"

echo | tee -a "$REPORT"
echo "[METHOD CHECK]" | tee -a "$REPORT"

while IFS=',' read -r PATH STATUS METHOD TYPE SIZE TIME
do

    [ "$PATH" = "PATH" ] && continue

    URL="${BASE_URL}/${PATH#/}"

    for HTTP_METHOD in OPTIONS HEAD
    do

        METHOD_STATUS=$(curl -ks \
            -o /dev/null \
            -w "%{http_code}" \
            -X "$HTTP_METHOD" \
            --connect-timeout 3 \
            --max-time 8 \
            "$URL" 2>/dev/null)

        echo "$PATH -> $HTTP_METHOD : HTTP $METHOD_STATUS" |
            tee -a "$REPORT"

    done

done < "$RESULTS"

echo | tee -a "$REPORT"
echo "============================================" | tee -a "$REPORT"
echo "                 SUMMARY" | tee -a "$REPORT"
echo "============================================" | tee -a "$REPORT"

echo "Paths tested     : $TOTAL" | tee -a "$REPORT"
echo "Endpoints found  : $FOUND" | tee -a "$REPORT"
echo "CSV results      : $RESULTS" | tee -a "$REPORT"
echo "Full report      : $REPORT" | tee -a "$REPORT"

echo "============================================" | tee -a "$REPORT"
```

```bash

