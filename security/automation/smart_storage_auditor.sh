```bash
#!/bin/bash

# Smart Storage Auditor
# Audits disk usage, large files, old files, inode usage,
# mount points, and storage growth without deleting anything.

set -uo pipefail

TARGET="${1:-$HOME}"
REPORT="storage_audit_$(date +%Y%m%d_%H%M%S).txt"

if [ ! -d "$TARGET" ]; then
    echo "Error: Directory does not exist: $TARGET"
    exit 1
fi

TARGET=$(realpath "$TARGET")
WARNINGS=0

log() {
    printf '%s\n' "$1" | tee -a "$REPORT"
}

section() {
    log ""
    log "========== $1 =========="
}

log "SMART STORAGE AUDITOR"
log "Date: $(date)"
log "Target: $TARGET"

section "FILESYSTEM USAGE"

df -hT | tee -a "$REPORT"

section "INODE USAGE"

df -i | tee -a "$REPORT"

while read -r USAGE MOUNT; do
    if [[ "$USAGE" =~ ^[0-9]+%$ ]]; then
        VALUE="${USAGE%\%}"
        if (( VALUE >= 90 )); then
            log "[WARNING] Filesystem $MOUNT is ${VALUE}% full"
            ((WARNINGS+=1))
        fi
    fi
done < <(df -P | awk 'NR>1 {print $5, $6}')

section "TARGET SIZE"

du -sh "$TARGET" 2>/dev/null | tee -a "$REPORT"

section "LARGEST FILES"

find "$TARGET" -xdev -type f -printf '%s %p\n' 2>/dev/null |
    sort -nr |
    head -n 20 |
    while read -r SIZE PATH; do
        HUMAN=$(numfmt --to=iec --suffix=B "$SIZE" 2>/dev/null || echo "$SIZE bytes")
        printf '%-12s %s\n' "$HUMAN" "$PATH"
    done | tee -a "$REPORT"

section "DIRECTORY SIZES"

du -x -h --max-depth=1 "$TARGET" 2>/dev/null |
    sort -hr |
    head -n 20 |
    tee -a "$REPORT"

section "FILES NOT MODIFIED IN 90 DAYS"

find "$TARGET" -xdev -type f -mtime +90 \
    -printf '%TY-%Tm-%Td %s %p\n' 2>/dev/null |
    sort |
    head -n 50 |
    tee -a "$REPORT"

section "EMPTY FILES"

find "$TARGET" -xdev -type f -empty \
    -printf '%p\n' 2>/dev/null |
    head -n 100 |
    tee -a "$REPORT"

section "LARGE FILES OVER 500 MB"

find "$TARGET" -xdev -type f -size +500M \
    -printf '%s %p\n' 2>/dev/null |
    sort -nr |
    while read -r SIZE PATH; do
        HUMAN=$(numfmt --to=iec --suffix=B "$SIZE" 2>/dev/null || echo "$SIZE bytes")
        printf '%-12s %s\n' "$HUMAN" "$PATH"
    done | tee -a "$REPORT"

section "FILESYSTEM WARNING SUMMARY"

log "Warnings: $WARNINGS"
log "Report saved to: $REPORT"
log "Audit complete. No files were deleted or modified."
```
