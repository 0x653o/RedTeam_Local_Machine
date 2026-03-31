# Machine 14: joombleed -- CVE-2023-23752 Walkthrough

## Overview
- **CVE**: CVE-2023-23752 (CVSS 7.5)
- **Kill Chain**: nmap -> Joomla 80 -> API info leak -> DB creds -> admin login -> template editor PHP -> sudo miscfg -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.14.10
# Port 80 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 80. Research CVE-2023-23752.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.14.10 --port 80
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Sudo misconfiguration
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
