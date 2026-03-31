#!/bin/bash
# Machine 19: PickleRick — Setup privesc path
# Store root SSH key in Redis for the player to find after getting shell

# Generate SSH key pair for root
ssh-keygen -t rsa -b 2048 -f /tmp/root_key -N "" -q
mkdir -p /root/.ssh
cp /tmp/root_key.pub /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
chmod 700 /root/.ssh

# Enable root SSH login
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Start Redis and store the private key in it
redis-server --daemonize yes --bind 127.0.0.1 --port 6379
sleep 1
redis-cli SET "backup:ssh_key" "$(cat /tmp/root_key)"
redis-cli SET "backup:note" "Private SSH key for emergency root access"
redis-cli SET "app:db_password" "pickle_r1ck_2024"
rm /tmp/root_key /tmp/root_key.pub

echo "[*] PickleRick privesc setup complete (root SSH key in Redis)"
