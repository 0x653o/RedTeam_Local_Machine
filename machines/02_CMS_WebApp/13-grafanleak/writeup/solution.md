# Machine 13: grafanleak -- CVE-2021-43798 Walkthrough

## Overview
- **CVE**: CVE-2021-43798 (CVSS 7.5)
- **Kill Chain**: nmap -> Grafana 3000 -> plugin path traversal -> read config -> SQLite download -> extract creds -> SSH -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.13.10
# Port 3000 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 3000. Research CVE-2021-43798.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.13.10 --port 3000
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Credential spray via SSH
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
