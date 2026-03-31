#!/bin/bash
# Setup a writable cron script for privilege escalation
mkdir -p /opt/scripts
cat > /opt/scripts/backup.sh << 'CRONSCRIPT'
#!/bin/bash
# Automated backup script
tar czf /tmp/backup-$(date +%s).tar.gz /var/log/ 2>/dev/null
CRONSCRIPT
chmod 777 /opt/scripts/backup.sh
echo "* * * * * root /opt/scripts/backup.sh" > /etc/cron.d/backup-job
chmod 644 /etc/cron.d/backup-job
cron
