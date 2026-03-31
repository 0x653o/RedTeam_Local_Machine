# Machine 10: bulletproof -- CVE-2019-16759 Walkthrough

## Overview
- **CVE**: CVE-2019-16759 (CVSS 9.8)
- **Kill Chain**: nmap -> vBulletin 80 -> widgetConfig RCE -> discover hidden cronjob -> write cron path -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.10.10
# Port 80 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 80. Research CVE-2019-16759.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.10.10 --port 80
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Hidden cronjob hijack
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
