#!/bin/bash
# Machine 02: SpringBreak — Health Check
HEALTHY=true

# 1. Tomcat listening on 8080
if ! ss -tlnp 2>/dev/null | grep -q ":8080 "; then
    echo "[UNHEALTHY] Port 8080 not listening"
    HEALTHY=false
fi

# 2. Spring app responds
if ! curl -sf -o /dev/null http://localhost:8080/springapp/ 2>/dev/null; then
    echo "[UNHEALTHY] Spring app not responding"
    HEALTHY=false
fi

# 3. Flag files
[ -f /root/root.txt ] || { echo "[UNHEALTHY] Root flag missing"; HEALTHY=false; }
[ -f /home/user/user.txt ] || { echo "[UNHEALTHY] User flag missing"; HEALTHY=false; }

# 4. Cron privesc path exists
[ -f /opt/scripts/backup.sh ] || { echo "[UNHEALTHY] Cron script missing"; HEALTHY=false; }

if [ "$HEALTHY" = true ]; then echo "[HEALTHY] All checks passed"; exit 0; else exit 1; fi
