#!/bin/bash
set -e
SEED="${FLAG_SEED:-default-seed}"
MID="${MACHINE_ID:-00}"
ROOT_FLAG=$(echo -n "${SEED}:machine_${MID}" | sha256sum | cut -c1-32)
USER_FLAG=$(echo -n "${SEED}:user_${MID}" | sha256sum | cut -c1-32)
echo "FLAG{${ROOT_FLAG}}" > /root/root.txt; chmod 400 /root/root.txt
mkdir -p /home/user
echo "FLAG{${USER_FLAG}}" > /home/user/user.txt
chown user:user /home/user/user.txt 2>/dev/null || true; chmod 444 /home/user/user.txt
mkdir -p /var/run/sshd; ssh-keygen -A 2>/dev/null || true
/usr/sbin/sshd 2>/dev/null &
[ -f /opt/config/setup.sh ] && chmod +x /opt/config/setup.sh && /opt/config/setup.sh
echo "[*] Machine ${MID} starting..."
if [ -f /opt/config/start-service.sh ]; then
    chmod +x /opt/config/start-service.sh; exec /opt/config/start-service.sh
else
    tail -f /dev/null
fi
