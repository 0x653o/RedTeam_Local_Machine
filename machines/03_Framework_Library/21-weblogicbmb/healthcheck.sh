#!/bin/bash
# Health check for machine 21: weblogicbmb
check_ok=true
if ! ss -tlnp 2>/dev/null | grep -q ":7001 "; then
    echo "[UNHEALTHY] Port 7001 not listening"; check_ok=false
fi
[ -f /root/root.txt ] || { echo "[UNHEALTHY] Root flag missing"; check_ok=false; }
[ -f /home/user/user.txt ] || { echo "[UNHEALTHY] User flag missing"; check_ok=false; }
if [ "$check_ok" = true ]; then echo "[HEALTHY] All checks passed"; exit 0; else exit 1; fi
