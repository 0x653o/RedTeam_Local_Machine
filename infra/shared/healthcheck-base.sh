#!/bin/bash
# ──────────────────────────────────────────────────────
# Local-Machine — Base Health Check Template
# ──────────────────────────────────────────────────────
# Source this in each machine's healthcheck.sh to get
# common health check utilities.
#
# Usage in machine healthcheck.sh:
#   #!/bin/bash
#   source /opt/healthcheck-base.sh
#   check_port 8080
#   check_flag_files
#   check_service_vuln "curl -s http://localhost:8080/ | grep -q 'Expected'"
#   exit_healthcheck
# ──────────────────────────────────────────────────────

HEALTH_STATUS=0
HEALTH_MESSAGES=()

# Check if a port is listening
check_port() {
    local port="$1"
    local description="${2:-Port ${port}}"
    
    if ss -tlnp | grep -q ":${port} "; then
        HEALTH_MESSAGES+=("[✓] ${description} is listening")
    else
        HEALTH_MESSAGES+=("[✗] ${description} is NOT listening")
        HEALTH_STATUS=1
    fi
}

# Check if flag files exist and are readable
check_flag_files() {
    if [ -f /root/root.txt ] && [ -r /root/root.txt ]; then
        HEALTH_MESSAGES+=("[✓] Root flag exists")
    else
        HEALTH_MESSAGES+=("[✗] Root flag missing or unreadable")
        HEALTH_STATUS=1
    fi

    if [ -f /home/user/user.txt ] && [ -r /home/user/user.txt ]; then
        HEALTH_MESSAGES+=("[✓] User flag exists")
    else
        HEALTH_MESSAGES+=("[✗] User flag missing or unreadable")
        HEALTH_STATUS=1
    fi
}

# Check if the vulnerability is still exploitable (lightweight test)
check_service_vuln() {
    local test_command="$1"
    local description="${2:-Vulnerability check}"

    if eval "${test_command}" 2>/dev/null; then
        HEALTH_MESSAGES+=("[✓] ${description} passed")
    else
        HEALTH_MESSAGES+=("[✗] ${description} FAILED — service may not be exploitable")
        HEALTH_STATUS=1
    fi
}

# Check if a process is running
check_process() {
    local process_name="$1"
    local description="${2:-Process ${process_name}}"

    if pgrep -f "${process_name}" > /dev/null 2>&1; then
        HEALTH_MESSAGES+=("[✓] ${description} is running")
    else
        HEALTH_MESSAGES+=("[✗] ${description} is NOT running")
        HEALTH_STATUS=1
    fi
}

# Check HTTP response code
check_http() {
    local url="$1"
    local expected_code="${2:-200}"
    local description="${3:-HTTP ${url}}"

    local actual_code
    actual_code=$(curl -sk -o /dev/null -w '%{http_code}' "${url}" 2>/dev/null || echo "000")
    
    if [ "${actual_code}" = "${expected_code}" ]; then
        HEALTH_MESSAGES+=("[✓] ${description} returned ${actual_code}")
    else
        HEALTH_MESSAGES+=("[✗] ${description} returned ${actual_code} (expected ${expected_code})")
        HEALTH_STATUS=1
    fi
}

# Final health check exit
exit_healthcheck() {
    for msg in "${HEALTH_MESSAGES[@]}"; do
        echo "${msg}"
    done
    
    if [ ${HEALTH_STATUS} -eq 0 ]; then
        echo "[HEALTHY] All checks passed"
    else
        echo "[UNHEALTHY] Some checks failed"
    fi
    
    exit ${HEALTH_STATUS}
}
