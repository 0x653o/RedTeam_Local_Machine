#!/bin/bash
# Flag generation script for Machine 01
SEED="${FLAG_SEED:-default-seed}"
MACHINE_ID="01"

ROOT_FLAG=$(echo -n "${SEED}:machine_${MACHINE_ID}" | sha256sum | cut -c1-32)
USER_FLAG=$(echo -n "${SEED}:user_${MACHINE_ID}" | sha256sum | cut -c1-32)

echo "FLAG{${ROOT_FLAG}}" > /root/root.txt
chmod 400 /root/root.txt

mkdir -p /home/user
echo "FLAG{${USER_FLAG}}" > /home/user/user.txt
chown user:user /home/user/user.txt
chmod 444 /home/user/user.txt

echo "[+] Flags generated for machine ${MACHINE_ID}"
