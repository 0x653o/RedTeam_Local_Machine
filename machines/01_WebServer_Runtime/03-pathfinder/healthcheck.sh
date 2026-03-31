#!/bin/bash
source /opt/healthcheck-base.sh 2>/dev/null || { check_port() { ss -tlnp | grep -q ":${1} "; }; check_flag_files() { [ -f /root/root.txt ] && [ -f /home/user/user.txt ]; }; exit_healthcheck() { exit 0; }; }
check_port 80 "Apache HTTP"
check_flag_files
exit_healthcheck
