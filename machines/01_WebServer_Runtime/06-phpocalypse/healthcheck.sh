#!/bin/bash
# ──────────────────────────────────────────────────────
# Machine 06: PHPocalypse — Health Check
# ──────────────────────────────────────────────────────
HEALTHY=true

# 1. Apache listening on port 80
if ! ss -tlnp 2>/dev/null | grep -q ':80 '; then
    echo "[UNHEALTHY] Port 80 not listening"
    HEALTHY=false
fi

# 2. PHP-CGI accessible
if ! curl -sf -o /dev/null http://localhost/index.php 2>/dev/null; then
    echo "[UNHEALTHY] PHP app not responding on port 80"
    HEALTHY=false
fi

# 3. php-cgi binary exists at expected CGI path
if [ ! -f /usr/lib/cgi-bin/php-cgi ]; then
    echo "[UNHEALTHY] php-cgi binary missing from /usr/lib/cgi-bin/"
    HEALTHY=false
fi

# 4. Flag files exist
[ ! -f /root/root.txt ] && echo "[UNHEALTHY] root flag missing" && HEALTHY=false
[ ! -f /home/user/user.txt ] && echo "[UNHEALTHY] user flag missing" && HEALTHY=false

# 5. Writable cron script exists (privesc vector)
if [ ! -f /opt/scripts/backup.sh ]; then
    echo "[UNHEALTHY] Privesc cron script missing"
    HEALTHY=false
fi

[ "$HEALTHY" = true ] && echo "[HEALTHY] All checks passed" && exit 0 || exit 1
