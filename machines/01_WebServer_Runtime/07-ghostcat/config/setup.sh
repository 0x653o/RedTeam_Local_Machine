#!/bin/bash
# Machine 07: GhostCat — Setup
# tomcat user gets sudo find for privilege escalation (same pattern as Machine 04)

echo "tomcat ALL=(ALL) NOPASSWD: /usr/bin/find" > /etc/sudoers.d/tomcat
chmod 440 /etc/sudoers.d/tomcat

# Place user flag in tomcat home (reachable after initial shell)
mkdir -p /home/tomcat
if [ -f /home/user/user.txt ]; then
    cp /home/user/user.txt /home/tomcat/user.txt
    chown tomcat:tomcat /home/tomcat/user.txt
fi

echo "[*] GhostCat setup complete"
echo "[*] Privesc: tomcat user can run 'sudo find . -exec /bin/sh -p \\;'"
