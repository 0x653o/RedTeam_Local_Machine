# Machine 34: apachenght -- CVE-2023-25690 Walkthrough

## Overview
- **CVE**: CVE-2023-25690 (CVSS 9.8)
- **Kill Chain**: nmap -> Apache proxy 80 -> request smuggling -> bypass auth -> management API -> RCE -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.34.10
# Port 80 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 80. Research CVE-2023-25690.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.34.10 --port 80
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Request smuggling
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
