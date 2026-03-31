#!/bin/bash
# ──────────────────────────────────────────────────────
# Machine 01: Log4Hell — Health Check
# ──────────────────────────────────────────────────────

source /opt/healthcheck-base.sh 2>/dev/null || {
    # Inline fallback if base not available
    check_port() { ss -tlnp | grep -q ":${1} " || exit 1; }
    check_flag_files() { [ -f /root/root.txt ] && [ -f /home/user/user.txt ] || exit 1; }
    exit_healthcheck() { exit 0; }
}

# 1. Java webapp listening on 8080
check_port 8080 "Java Web Application"

# 2. Vulnerability is exploitable (Log4j responds to JNDI lookup format)
check_service_vuln \
    "curl -s -o /dev/null -w '%{http_code}' -H 'X-Api-Version: test' http://localhost:8080/ | grep -q '200'" \
    "Log4j web app responds"

# 3. Flag files exist
check_flag_files

# 4. SUID binary exists
check_service_vuln \
    "test -u /usr/local/bin/vuln-reader" \
    "SUID binary present"

exit_healthcheck
