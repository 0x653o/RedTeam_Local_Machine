#!/bin/bash
# ──────────────────────────────────────────────────────
# Machine 01: Log4Hell — Health Check
# ──────────────────────────────────────────────────────

HEALTHY=true

# 1. Java webapp listening on 8080
if ! ss -tlnp 2>/dev/null | grep -q ":8080 "; then
    echo "[UNHEALTHY] Port 8080 not listening"
    HEALTHY=false
fi

# 2. Web app responds to HTTP requests
if ! curl -sf -o /dev/null -w '' http://localhost:8080/ 2>/dev/null; then
    echo "[UNHEALTHY] Web app not responding on 8080"
    HEALTHY=false
fi

# 3. Flag files exist
if [ ! -f /root/root.txt ]; then
    echo "[UNHEALTHY] Root flag missing"
    HEALTHY=false
fi
if [ ! -f /home/user/user.txt ]; then
    echo "[UNHEALTHY] User flag missing"
    HEALTHY=false
fi

# 4. SUID binary exists and has SUID bit set
if [ ! -u /usr/local/bin/vuln-reader ]; then
    echo "[UNHEALTHY] SUID binary missing or not SUID"
    HEALTHY=false
fi

if [ "$HEALTHY" = true ]; then
    echo "[HEALTHY] All checks passed"
    exit 0
else
    exit 1
fi
