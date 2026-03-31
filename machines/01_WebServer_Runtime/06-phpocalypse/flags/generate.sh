#!/bin/bash
SEED="${FLAG_SEED:-default-seed}"; MID="06"
echo "FLAG{$(echo -n "${SEED}:machine_${MID}" | sha256sum | cut -c1-32)}" > /root/root.txt; chmod 400 /root/root.txt
mkdir -p /home/user; echo "FLAG{$(echo -n "${SEED}:user_${MID}" | sha256sum | cut -c1-32)}" > /home/user/user.txt
chown user:user /home/user/user.txt 2>/dev/null; chmod 444 /home/user/user.txt
