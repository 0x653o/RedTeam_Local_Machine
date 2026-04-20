#!/bin/bash
# Machine 06: PHPocalypse — Privilege escalation setup
# Cron script /opt/scripts/backup.sh is world-writable → write shell → root

# Ensure backup script is writable by www-data
chmod 777 /opt/scripts/backup.sh

# Create cron entry if not already present
if ! grep -q backup /etc/crontab 2>/dev/null; then
    echo '* * * * * root /opt/scripts/backup.sh' >> /etc/crontab
fi

# Start cron daemon (needed for cron-based privesc)
service cron start 2>/dev/null || cron 2>/dev/null &

echo "[*] PHPocalypse privesc setup complete"
echo "[*] Writable cron script: /opt/scripts/backup.sh (runs as root every minute)"
