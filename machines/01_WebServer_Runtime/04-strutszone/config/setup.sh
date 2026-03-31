#!/bin/bash
# Machine 04: StrutsZone — Setup privileged escalation via sudo find
# The tomcat user can run find as root — exploitable via find -exec

echo "tomcat ALL=(ALL) NOPASSWD: /usr/bin/find" >> /etc/sudoers.d/tomcat
chmod 440 /etc/sudoers.d/tomcat

echo "[*] StrutsZone privesc setup complete (sudo find for tomcat user)"
