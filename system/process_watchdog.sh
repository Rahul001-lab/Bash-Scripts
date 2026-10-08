#!/bin/bash

# Process Watchdog
# Monitors selected processes and records crashes/restarts.

set -u

CONFIG="${1:-processes.txt}"
LOG_DIR="process_watchdog_logs"

mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/watchdog_$(date +%Y%m%d).log"

if [ ! -f "$CONFIG" ]; then
    echo "Error: Config file not found: $CONFIG"
    echo
    echo "Create one with process names, one per line:"
    echo "  sshd"
    echo "  NetworkManager"
    echo "  python3"
    exit 1
fi

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" |
        tee -a "$LOG_FILE"
}

check_process() {

    PROCESS="$1"

    PID=$(pgrep -xo "$PROCESS" 2>/dev/null || true)

    if [ -n "$PID" ]; then

        CPU=$(ps -p "$PID" -o %cpu= |
            awk '{printf "%.1f", $1}')

        MEM=$(ps -p "$PID" -o %mem= |
            awk '{printf "%.1f", $1}')

        UPTIME=$(ps -p "$PID" -o etime= |
            xargs)

        STATUS=$(ps -p "$PID" -o stat= |
            xargs)

        log "[RUNNING] $PROCESS | PID=$PID | CPU=${CPU}% | MEM=${MEM}% | TIME=$UPTIME | STATE=$STATUS"

    else

        log "[DOWN] $PROCESS is not running"

    fi
}

log "============================================"
log "             PROCESS WATCHDOG"
log "============================================"

while IFS= read -r PROCESS || [ -n "$PROCESS" ]
do

    PROCESS=$(echo "$PROCESS" | xargs)

    [ -z "$PROCESS" ] && continue
    [[ "$PROCESS" == \#* ]] && continue

    check_process "$PROCESS"

done < "$CONFIG"

log "============================================"
log "Watchdog check completed"
log "============================================"
