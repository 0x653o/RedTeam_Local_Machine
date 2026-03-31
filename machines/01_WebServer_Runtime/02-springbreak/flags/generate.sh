#!/bin/bash
SEED="${FLAG_SEED:-default-seed}"; MACHINE_ID="02"
echo "FLAG{$(echo -n "${SEED}:machine_${MACHINE_ID}" | sha256sum | cut -c1-32)}" > /root/root.txt
mkdir -p /home/user && echo "FLAG{$(echo -n "${SEED}:user_${MACHINE_ID}" | sha256sum | cut -c1-32)}" > /home/user/user.txt
chmod 400 /root/root.txt; chown user:user /home/user/user.txt; chmod 444 /home/user/user.txt
