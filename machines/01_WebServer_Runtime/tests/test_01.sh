#!/bin/bash
# Machine 01: Log4Hell — CVE-2021-44228 Test
# Tests: Java app on 8080, JNDI header logging, SUID binary, flags
source "$(dirname "$0")/_lib.sh"

BASE_DIR=${1:-$(dirname "$(dirname "$0")")}
CLEANUP=${2:-true}
MACHINE_DIR="$BASE_DIR/01-log4hell"
COMPOSE="$MACHINE_DIR/docker-compose.yml"
CONTAINER="lm-01-log4hell"
IP="10.10.1.10"

trap '[ "$CLEANUP" = true ] && stop_machine "$COMPOSE"' EXIT

section "Build & Start"
start_machine "$COMPOSE" "$CONTAINER" 90 || finish

section "Network Checks"
check_port "$IP" 8080 "Java HTTP"
check_port "$IP" 22   "SSH"

section "HTTP App Checks"
check_http "http://${IP}:8080/" 200 "Dashboard"
check_http_contains "http://${IP}:8080/" "Corporate Internal Dashboard" "Dashboard content"
check_http "http://${IP}:8080/api/login" 200 "Login page"
check_http "http://${IP}:8080/api/search" 200 "Search endpoint"

section "Log4j Vulnerability Check"
# Verify the app logs JNDI-injectable headers (response still 200)
resp=$(curl -sk -o /dev/null -w '%{http_code}' \
  -H 'X-Api-Version: ${jndi:ldap://127.0.0.1:1389/test}' \
  "http://${IP}:8080/" 2>/dev/null)
[ "$resp" = "200" ] && pass "App accepts JNDI payload in header (CVE-2021-44228 trigger point)" \
                     || fail "App rejected JNDI header (got HTTP $resp)"

section "Flags"
check_exec "$CONTAINER" "[ -f /root/root.txt ] && cat /root/root.txt" "FLAG{" "Root flag exists"
check_exec "$CONTAINER" "[ -f /home/user/user.txt ] && cat /home/user/user.txt" "FLAG{" "User flag exists"

section "SUID Binary (Privesc)"
check_exec "$CONTAINER" "ls -la /usr/local/bin/vuln-reader" "rws" "SUID bit set on vuln-reader"
check_exec "$CONTAINER" "/usr/local/bin/vuln-reader /root/root.txt" "FLAG{" "SUID reads root flag"

finish
