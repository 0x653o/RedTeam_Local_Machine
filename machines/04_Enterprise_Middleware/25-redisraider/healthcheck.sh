#!/bin/bash
# Health check for machine 25: redisraider
check_ok=true
if ! ss -tlnp 2>/dev/null | grep -q ":6379 "; then
    echo "[UNHEALTHY] Port 6379 not listening"; check_ok=false
fi
[ -f /root/root.txt ] || { echo "[UNHEALTHY] Root flag missing"; check_ok=false; }
[ -f /home/user/user.txt ] || { echo "[UNHEALTHY] User flag missing"; check_ok=false; }
if [ "$check_ok" = true ]; then echo "[HEALTHY] All checks passed"; exit 0; else exit 1; fi
