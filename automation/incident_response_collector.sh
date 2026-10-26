```bash
#!/bin/bash

# Linux Incident Response Collector
# Collects read-only system evidence for defensive investigation.

set -uo pipefail
umask 077

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="incident_report_$TIMESTAMP"

mkdir -p "$OUTPUT_DIR" || exit 1

SUMMARY="$OUTPUT_DIR/summary.txt"

log() {
    printf '[%s] %s\n' "$(date '+%F %T')" "$*" |
        tee -a "$SUMMARY"
}

collect() {
    local name="$1"
    shift

    {
        echo "Collection time: $(date)"
        echo "Command: $*"
        echo "----------------------------------------"
        "$@"
    } > "$OUTPUT_DIR/$name" 2>&1 || {
        echo "Collection incomplete; command may require additional permissions." \
            >> "$OUTPUT_DIR/$name"
    }
}

log "Incident response collection started"
log "Hostname: $(hostname)"
log "Output directory: $OUTPUT_DIR"

# 1. System identity and operating system
collect system_info.txt bash -c '
    hostnamectl 2>/dev/null || hostname
    echo
    cat /etc/os-release 2>/dev/null
    echo
    uname -a
    echo
    uptime
'

# 2. Current users and login sessions
collect logged_in_users.txt bash -c '
    who
    echo
    w
    echo
    last -n 30 2>/dev/null
'

# 3. Running processes
collect processes.txt ps auxf

# 4. Listening ports and connections
if command -v ss >/dev/null 2>&1; then
    collect network_connections.txt ss -tunap
else
    collect network_connections.txt netstat -tunap
fi

# 5. Network configuration
collect network_config.txt bash -c '
    ip address
    echo
    ip route
    echo
    cat /etc/resolv.conf 2>/dev/null
'

# 6. Failed service status
if command -v systemctl >/dev/null 2>&1; then
    collect failed_services.txt systemctl --failed --no-pager
fi

# 7. Recent authentication events
if command -v journalctl >/dev/null 2>&1; then
    collect auth_journal.txt journalctl \
        --since "24 hours ago" \
        --no-pager \
        -u ssh \
        -u sshd
fi

# Common authentication log locations
for FILE in /var/log/auth.log /var/log/secure; do
    if [[ -r "$FILE" ]]; then
        NAME=$(basename "$FILE")
        tail -n 1000 "$FILE" > "$OUTPUT_DIR/${NAME}_recent.txt" 2>&1
    fi
done

# 8. Recent system messages
if command -v journalctl >/dev/null 2>&1; then
    collect recent_system_logs.txt journalctl \
        --since "24 hours ago" \
        --no-pager \
        -p warning
fi

# 9. Recently modified files in common temporary locations
collect recent_temp_files.txt bash -c '
    for DIR in /tmp /var/tmp; do
        if [ -d "$DIR" ]; then
            echo "### $DIR"
            find "$DIR" -xdev -type f -mmin -1440 \
                -printf "%TY-%Tm-%Td %TH:%TM:%TS %s %u:%g %p\n" \
                2>/dev/null
        fi
    done
'

# 10. Scheduled tasks and enabled services
collect scheduled_tasks.txt bash -c '
    crontab -l 2>/dev/null
    echo
    ls -la /etc/cron.d /etc/cron.daily /etc/cron.hourly 2>/dev/null
'

if command -v systemctl >/dev/null 2>&1; then
    collect enabled_services.txt systemctl \
        list-unit-files --state=enabled --no-pager
fi

# 11. Record hashes of collected files
log "Generating SHA-256 checksums"

(
    cd "$OUTPUT_DIR" || exit 1
    find . -maxdepth 1 -type f ! -name SHA256SUMS -print0 |
        sort -z |
        xargs -0 -r sha256sum > SHA256SUMS
)

# 12. Final report
log "Collection completed"
log "Files collected: $(find "$OUTPUT_DIR" -maxdepth 1 -type f | wc -l)"
log "Checksums: $OUTPUT_DIR/SHA256SUMS"
log "Review files for sensitive information before sharing."

echo
echo "Incident response collection finished."
echo "Report directory: $OUTPUT_DIR"
echo "Summary: $SUMMARY"
```
