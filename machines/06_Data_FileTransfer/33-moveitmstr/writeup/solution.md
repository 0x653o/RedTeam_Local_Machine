# Machine 33: moveitmstr -- CVE-2023-34362 Walkthrough

## Overview
- **CVE**: CVE-2023-34362 (CVSS 9.8)
- **Kill Chain**: nmap -> MOVEit 443 -> SQLi session handling -> extract tokens -> impersonate sysadmin -> deser RCE -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.33.10
# Port 443 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 443. Research CVE-2023-34362.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.33.10 --port 443
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Deserialization chain
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
