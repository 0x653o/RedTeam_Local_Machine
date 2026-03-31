# Machine 17: imagetragick -- CVE-2016-3714 Walkthrough

## Overview
- **CVE**: CVE-2016-3714 (CVSS 8.4)
- **Kill Chain**: nmap -> image upload 80 -> MVG file cmd injection -> shell -> cron ImageMagick root -> poison input -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.17.10
# Port 80 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 80. Research CVE-2016-3714.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.17.10 --port 80
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Cron ImageMagick processing
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
