# Machine 11: confluencer -- CVE-2022-26134 Walkthrough

## Overview
- **CVE**: CVE-2022-26134 (CVSS 9.8)
- **Kill Chain**: nmap -> Confluence 8090 -> OGNL URL injection -> RCE -> SSH key in home -> key reuse for root -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.11.10
# Port 8090 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 8090. Research CVE-2022-26134.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.11.10 --port 8090
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: SSH key reuse
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
