#!/bin/bash
set -e
SEED="${FLAG_SEED:-default-seed}"
MACHINE_ID="${MACHINE_ID:-02}"
ROOT_FLAG=$(echo -n "${SEED}:machine_${MACHINE_ID}" | sha256sum | cut -c1-32)
USER_FLAG=$(echo -n "${SEED}:user_${MACHINE_ID}" | sha256sum | cut -c1-32)
echo "FLAG{${ROOT_FLAG}}" > /root/root.txt && chmod 400 /root/root.txt
mkdir -p /home/user && echo "FLAG{${USER_FLAG}}" > /home/user/user.txt
chown user:user /home/user/user.txt && chmod 444 /home/user/user.txt

# Setup vulnerable cron job (writable script run as root)
/opt/setup-cron.sh

# Start SSH
mkdir -p /var/run/sshd && ssh-keygen -A 2>/dev/null || true
/usr/sbin/sshd 2>/dev/null &

# Start Tomcat as tomcat user
echo "[*] SpringBreak machine starting..."
su -c "/opt/tomcat/bin/catalina.sh run" tomcat
