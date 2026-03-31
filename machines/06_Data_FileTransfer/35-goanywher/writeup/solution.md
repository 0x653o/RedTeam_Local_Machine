# Machine 35: goanywher -- CVE-2023-0669 Walkthrough

## Overview
- **CVE**: CVE-2023-0669 (CVSS 9.8)
- **Kill Chain**: nmap -> GoAnywhere 8000 -> License portal -> AES deser -> blind deser -> RCE -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.35.10
# Port 8000 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 8000. Research CVE-2023-0669.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.35.10 --port 8000
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Java deserialization
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
