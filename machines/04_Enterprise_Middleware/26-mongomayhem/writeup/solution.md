# Machine 26: mongomayhem -- Miscfg+NoSQLi Walkthrough

## Overview
- **CVE**: Miscfg+NoSQLi (CVSS 9.1)
- **Kill Chain**: nmap -> MongoDB 27017 + webapp 80 -> dump users collection -> admin creds -> NoSQLi admin -> RCE -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.26.10
# Port 80 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 80. Research Miscfg+NoSQLi.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.26.10 --port 80
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: NoSQLi command injection
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
