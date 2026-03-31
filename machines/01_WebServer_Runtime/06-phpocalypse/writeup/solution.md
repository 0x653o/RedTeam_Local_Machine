# Machine 06: phpocalypse -- CVE-2012-1823 Walkthrough

## Overview
- **CVE**: CVE-2012-1823 (CVSS 9.8)
- **Kill Chain**: nmap -> PHP-CGI 80 -> ?-s leaks source -> argument injection RCE -> writable cron -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.6.10
# Port 80 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 80. Research CVE-2012-1823.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.6.10 --port 80
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Writable cron script
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
