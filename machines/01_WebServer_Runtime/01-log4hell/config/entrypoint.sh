#!/bin/bash
# ──────────────────────────────────────────────────────
# Machine 01: Log4Hell — Container Entrypoint
# ──────────────────────────────────────────────────────

set -e

# Generate flags
SEED="${FLAG_SEED:-default-seed}"
MACHINE_ID="${MACHINE_ID:-01}"

ROOT_FLAG=$(echo -n "${SEED}:machine_${MACHINE_ID}" | sha256sum | cut -c1-32)
USER_FLAG=$(echo -n "${SEED}:user_${MACHINE_ID}" | sha256sum | cut -c1-32)

# Write root flag
echo "FLAG{${ROOT_FLAG}}" > /root/root.txt
chmod 400 /root/root.txt

# Write user flag
mkdir -p /home/user
echo "FLAG{${USER_FLAG}}" > /home/user/user.txt
chown user:user /home/user/user.txt
chmod 444 /home/user/user.txt

# Copy healthcheck base if available
if [ -f /opt/healthcheck-base.sh ]; then
    cp /opt/healthcheck-base.sh /opt/healthcheck-base.sh
fi

# Create log directories
mkdir -p /var/log/webapp

# Setup SSH (for post-exploitation realism)
mkdir -p /var/run/sshd
ssh-keygen -A 2>/dev/null || true

# Start SSH in background
/usr/sbin/sshd 2>/dev/null &

echo "[*] Log4Hell machine starting..."
echo "[*] Flags generated for machine ${MACHINE_ID}"

# Start the vulnerable application as appuser
su -c "/opt/webapp/start-app.sh" appuser
