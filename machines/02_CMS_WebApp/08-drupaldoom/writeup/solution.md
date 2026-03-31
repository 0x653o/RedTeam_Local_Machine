# Machine 08: drupaldoom -- CVE-2018-7600 Walkthrough

## Overview
- **CVE**: CVE-2018-7600 (CVSS 9.8)
- **Kill Chain**: nmap -> Drupal 80 -> Drupalgeddon2 RCE -> MySQL creds settings.php -> admin hash crack -> su sudo -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.8.10
# Port 80 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 80. Research CVE-2018-7600.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.8.10 --port 80
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Credential reuse + sudo
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
