#!/bin/bash
# Machine 03: PathFinder — Health Check
HEALTHY=true

# 1. Apache listening on 80
if ! ss -tlnp 2>/dev/null | grep -q ":80 "; then
    echo "[UNHEALTHY] Port 80 not listening"
    HEALTHY=false
fi

# 2. Apache responds
if ! curl -sf -o /dev/null http://localhost:80/ 2>/dev/null; then
    echo "[UNHEALTHY] Apache not responding"
    HEALTHY=false
fi

# 3. CGI scripts work
if ! curl -sf -o /dev/null http://localhost:80/cgi-bin/test.cgi 2>/dev/null; then
    echo "[UNHEALTHY] CGI not working"
    HEALTHY=false
fi

# 4. Flag files
[ -f /root/root.txt ] || { echo "[UNHEALTHY] Root flag missing"; HEALTHY=false; }
[ -f /home/user/user.txt ] || { echo "[UNHEALTHY] User flag missing"; HEALTHY=false; }

# 5. SUID binary
[ -u /usr/local/bin/file-reader ] || { echo "[UNHEALTHY] SUID binary missing"; HEALTHY=false; }

if [ "$HEALTHY" = true ]; then echo "[HEALTHY] All checks passed"; exit 0; else exit 1; fi
