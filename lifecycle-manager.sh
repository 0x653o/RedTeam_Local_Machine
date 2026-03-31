#!/bin/bash
# ──────────────────────────────────────────────────────
# Local-Machine — Lifecycle Manager
# ──────────────────────────────────────────────────────
# Daemon that monitors machine health and enforces
# automatic recovery and scheduled resets.
#
# Runs via cron every 60 seconds, or as a background
# process started by run.sh.
#
# Rules:
#   1. If uptime > MAX_INSTANCE_LIFETIME → RESET
#   2. If unhealthy (3 consecutive) → RESTART
#   3. If exited/dead → REVIVE
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.env" 2>/dev/null || true

MAX_LIFETIME="${MAX_INSTANCE_LIFETIME_MINUTES:-60}"
LOG_DIR="${LOG_DIR:-/var/log/local-machine}"
LOG_FILE="${LOG_DIR}/lifecycle.log"
CHECK_INTERVAL="${HEALTH_CHECK_INTERVAL_SECONDS:-30}"

# Create log directory
mkdir -p "${LOG_DIR}"

# ── Logging ───────────────────────────────────────────
log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${level}] $*" >> "${LOG_FILE}"
}

# ── Get container uptime in minutes ──────────────────
get_uptime_minutes() {
    local container="$1"
    local started_at
    started_at=$(docker inspect --format='{{.State.StartedAt}}' "${container}" 2>/dev/null || echo "")
    
    if [ -z "${started_at}" ] || [ "${started_at}" = "0001-01-01T00:00:00Z" ]; then
        echo "0"
        return
    fi
    
    local start_epoch
    local now_epoch
    start_epoch=$(date -d "${started_at}" +%s 2>/dev/null || echo "0")
    now_epoch=$(date +%s)
    
    echo $(( (now_epoch - start_epoch) / 60 ))
}

# ── Process a single machine ─────────────────────────
process_machine() {
    local compose_file="$1"
    local machine_name
    machine_name=$(basename "$(dirname "${compose_file}")")
    
    # Get container name
    local container
    container=$(docker compose -f "${compose_file}" ps --format '{{.Name}}' 2>/dev/null | head -1)
    
    if [ -z "${container}" ]; then
        # Container doesn't exist — REVIVE
        log "REVIVE" "${machine_name}: Container not found, starting..."
        docker compose -f "${compose_file}" up -d 2>/dev/null && \
            log "OK" "${machine_name}: Revived successfully" || \
            log "ERROR" "${machine_name}: Failed to revive"
        return
    fi
    
    # Get container status
    local status
    status=$(docker inspect --format='{{.State.Status}}' "${container}" 2>/dev/null || echo "unknown")
    
    case "${status}" in
        running)
            # Check uptime — RESET if over max lifetime
            local uptime
            uptime=$(get_uptime_minutes "${container}")
            
            if [ "${uptime}" -ge "${MAX_LIFETIME}" ]; then
                log "RESET" "${machine_name}: Uptime ${uptime}m >= ${MAX_LIFETIME}m, resetting..."
                docker compose -f "${compose_file}" down -v 2>/dev/null
                docker compose -f "${compose_file}" up -d 2>/dev/null && \
                    log "OK" "${machine_name}: Reset complete" || \
                    log "ERROR" "${machine_name}: Reset failed"
                return
            fi
            
            # Check health — RESTART if unhealthy
            local health
            health=$(docker inspect --format='{{.State.Health.Status}}' "${container}" 2>/dev/null || echo "none")
            
            if [ "${health}" = "unhealthy" ]; then
                log "RESTART" "${machine_name}: Unhealthy, restarting..."
                docker compose -f "${compose_file}" restart 2>/dev/null && \
                    log "OK" "${machine_name}: Restarted" || \
                    log "ERROR" "${machine_name}: Restart failed"
            fi
            ;;
        exited|dead)
            # Container died — REVIVE
            log "REVIVE" "${machine_name}: Status is ${status}, reviving..."
            docker compose -f "${compose_file}" up -d 2>/dev/null && \
                log "OK" "${machine_name}: Revived" || \
                log "ERROR" "${machine_name}: Revive failed"
            ;;
        *)
            log "WARN" "${machine_name}: Unknown status '${status}'"
            ;;
    esac
}

# ── Cleanup old logs ──────────────────────────────────
cleanup_logs() {
    local retention="${LOG_RETENTION_DAYS:-7}"
    find "${LOG_DIR}" -name "*.log" -mtime "+${retention}" -delete 2>/dev/null || true
}

# ── Main Loop ─────────────────────────────────────────
main() {
    log "START" "Lifecycle manager starting (interval: ${CHECK_INTERVAL}s, max lifetime: ${MAX_LIFETIME}m)"
    
    while true; do
        # Find all machine compose files
        while IFS= read -r compose_file; do
            process_machine "${compose_file}" || true
        done < <(find "${SCRIPT_DIR}/machines" -name "docker-compose.yml" -not -name "docker-compose.*.yml" | sort)
        
        # Periodic log cleanup
        cleanup_logs
        
        sleep "${CHECK_INTERVAL}"
    done
}

# Run as daemon or single pass
if [ "${1:-}" = "--once" ]; then
    while IFS= read -r compose_file; do
        process_machine "${compose_file}" || true
    done < <(find "${SCRIPT_DIR}/machines" -name "docker-compose.yml" -not -name "docker-compose.*.yml" | sort)
else
    main
fi
