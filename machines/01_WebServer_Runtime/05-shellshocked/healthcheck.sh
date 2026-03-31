#!/bin/bash
# Health check for machine 05: shellshocked
check_ok=true
if ! ss -tlnp 2>/dev/null | grep -q ":80 "; then
    echo "[UNHEALTHY] Port 80 not listening"; check_ok=false
fi
[ -f /root/root.txt ] || { echo "[UNHEALTHY] Root flag missing"; check_ok=false; }
[ -f /home/user/user.txt ] || { echo "[UNHEALTHY] User flag missing"; check_ok=false; }
if [ "$check_ok" = true ]; then echo "[HEALTHY] All checks passed"; exit 0; else exit 1; fi
