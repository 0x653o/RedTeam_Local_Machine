# Machine 37: pwnkit -- CVE-2021-4034 Walkthrough

## Overview
- **CVE**: CVE-2021-4034 (CVSS 7.8)
- **Kill Chain**: nmap -> Python 5000 -> Jinja2 SSTI -> low shell -> polkit pkexec env var injection -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.37.10
# Port 5000 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 5000. Research CVE-2021-4034.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.37.10 --port 5000
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: pkexec env variable injection
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
