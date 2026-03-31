#!/bin/bash
# Machine 25: RedisRaider — Setup privesc path
# Enable root SSH login and ensure .ssh directory exists

# Allow root SSH login with key
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Create root .ssh directory (needed for Redis key write attack)
mkdir -p /root/.ssh
chmod 700 /root/.ssh
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Create Redis log directory
mkdir -p /var/log/redis /var/lib/redis
chown redis:redis /var/log/redis /var/lib/redis 2>/dev/null || true

# Seed some data into Redis for realism
redis-cli SET company:name "AcmeCorp" 2>/dev/null &
redis-cli SET admin:email "admin@acme.local" 2>/dev/null &
redis-cli SET db:password "Str0ngP@ssw0rd!" 2>/dev/null &

echo "[*] RedisRaider privesc setup complete (root SSH + no-auth Redis)"
