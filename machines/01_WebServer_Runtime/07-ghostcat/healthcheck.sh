#!/bin/bash
# Machine 07: GhostCat — Health Check
HEALTHY=true

# 1. AJP port 8009 listening
if ! ss -tlnp 2>/dev/null | grep -q ':8009 '; then
    echo "[UNHEALTHY] AJP port 8009 not listening"
    HEALTHY=false
fi

# 2. HTTP port 8080 listening
if ! ss -tlnp 2>/dev/null | grep -q ':8080 '; then
    echo "[UNHEALTHY] HTTP port 8080 not listening"
    HEALTHY=false
fi

# 3. Tomcat responds to HTTP
if ! curl -sf -o /dev/null http://localhost:8080/app/ 2>/dev/null; then
    echo "[UNHEALTHY] Tomcat app not responding on 8080"
    HEALTHY=false
fi

# 4. WEB-INF/web.xml exists (the target file for Ghostcat)
if [ ! -f /opt/tomcat/webapps/app/WEB-INF/web.xml ]; then
    echo "[UNHEALTHY] WEB-INF/web.xml missing (Ghostcat target file)"
    HEALTHY=false
fi

# 5. Tomcat Manager accessible
if ! curl -sf -o /dev/null http://localhost:8080/manager/ 2>/dev/null; then
    echo "[WARN] Tomcat Manager not reachable (may require auth)"
fi

# 6. Flag files
[ ! -f /root/root.txt ] && echo "[UNHEALTHY] root flag missing" && HEALTHY=false
[ ! -f /home/user/user.txt ] && echo "[UNHEALTHY] user flag missing" && HEALTHY=false

[ "$HEALTHY" = true ] && echo "[HEALTHY] All checks passed" && exit 0 || exit 1
