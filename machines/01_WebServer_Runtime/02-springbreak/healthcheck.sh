#!/bin/bash
source /opt/healthcheck-base.sh 2>/dev/null || {
    check_port() { ss -tlnp | grep -q ":${1} " || exit 1; }
    check_flag_files() { [ -f /root/root.txt ] && [ -f /home/user/user.txt ] || exit 1; }
    check_service_vuln() { eval "$1" 2>/dev/null || exit 1; }
    exit_healthcheck() { exit 0; }
}
check_port 8080 "Spring Boot / Tomcat"
check_service_vuln "curl -s http://localhost:8080/actuator 2>/dev/null | grep -q 'health\|status'" "Spring Actuator endpoint"
check_flag_files
exit_healthcheck
