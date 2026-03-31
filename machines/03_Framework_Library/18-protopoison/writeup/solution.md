# Machine 18: protopoison -- CWE-1321 Walkthrough

## Overview
- **CVE**: CWE-1321 (CVSS 9.8)
- **Kill Chain**: nmap -> Node.js API 3000 -> fuzz JSON -> __proto__ pollution -> EJS template options -> SSTI -> RCE -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.18.10
# Port 3000 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 3000. Research CWE-1321.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.18.10 --port 3000
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Container runs as root
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
