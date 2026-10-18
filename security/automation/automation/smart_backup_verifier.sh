```bash
#!/bin/bash

# Smart Backup Verifier
# Creates and verifies SHA-256 manifests for backup files.
# Never modifies or deletes the files being checked.

set -uo pipefail

MODE="${1:-}"
TARGET="${2:-}"
MANIFEST="${3:-}"

usage() {
    echo "Usage:"
    echo "  $0 create <directory> <manifest-file>"
    echo "  $0 verify <directory> <manifest-file>"
    exit 1
}

[[ "$MODE" == "create" || "$MODE" == "verify" ]] || usage
[[ -d "$TARGET" && -n "$MANIFEST" ]] || usage

TARGET=$(realpath "$TARGET")
MANIFEST=$(realpath -m "$MANIFEST")
REPORT="backup_audit_$(date +%Y%m%d_%H%M%S).txt"

if [[ "$MANIFEST" == "$TARGET/"* ]]; then
    echo "Error: Store the manifest outside the directory being audited."
    exit 1
fi

log() {
    echo "$1" | tee -a "$REPORT"
}

log "========================================"
log "       SMART BACKUP VERIFIER"
log "========================================"
log "Mode: $MODE"
log "Target: $TARGET"
log "Manifest: $MANIFEST"
log "Date: $(date)"
log ""

if [[ "$MODE" == "create" ]]; then
    TEMP=$(mktemp)
    trap 'rm -f "$TEMP"' EXIT

    log "[*] Generating SHA-256 manifest..."

    if ! find "$TARGET" -type f -print0 |
        sort -z |
        while IFS= read -r -d '' FILE; do
            sha256sum -- "$FILE"
        done > "$TEMP"; then
        log "[ERROR] Manifest generation failed."
        exit 1
    fi

    if ! mv -- "$TEMP" "$MANIFEST"; then
        log "[ERROR] Could not save manifest."
        exit 1
    fi

    trap - EXIT

    COUNT=$(wc -l < "$MANIFEST")
    log "[PASS] Manifest created successfully."
    log "Files recorded: $COUNT"

else
    if [[ ! -f "$MANIFEST" ]]; then
        log "[ERROR] Manifest not found."
        exit 1
    fi

    log "[*] Verifying recorded files..."

    VERIFIED=0
    MODIFIED=0
    MISSING=0

    while IFS= read -r LINE || [[ -n "$LINE" ]]; do
        [[ -z "$LINE" ]] && continue

        HASH="${LINE:0:64}"
        FILE="${LINE:66}"

        # Reject malformed manifest entries and paths outside target.
        if [[ ! "$HASH" =~ ^[a-fA-F0-9]{64}$ ||
              ! "$FILE" == /* ]]; then
            log "[ERROR] Invalid manifest entry: $LINE"
            continue
        fi

        if [[ "$FILE" != "$TARGET/"* ]]; then
            log "[ERROR] Path outside target: $FILE"
            continue
        fi

        if [[ ! -f "$FILE" ]]; then
            log "[MISSING] $FILE"
            ((MISSING+=1))
            continue
        fi

        ACTUAL=$(sha256sum -- "$FILE" | awk '{print $1}')

        if [[ "$ACTUAL" == "$HASH" ]]; then
            ((VERIFIED+=1))
        else
            log "[MODIFIED] $FILE"
            ((MODIFIED+=1))
        fi
    done < "$MANIFEST"

    log ""
    log "Verification summary:"
    log "Verified: $VERIFIED"
    log "Modified: $MODIFIED"
    log "Missing: $MISSING"

    if (( MODIFIED > 0 || MISSING > 0 )); then
        log "[WARN] Backup integrity issues detected."
    else
        log "[PASS] All recorded files verified."
    fi
fi

log ""
log "Report saved to: $REPORT"
log "========================================"
```
