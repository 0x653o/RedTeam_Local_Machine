# Machine 23: jenkinsowned -- CVE-2024-23897 Walkthrough

## Overview
- **CVE**: CVE-2024-23897 (CVSS 9.8)
- **Kill Chain**: nmap -> Jenkins 8080 -> CLI argument file read -> leak master.key -> decrypt SSH creds -> SSH root -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.23.10
# Port 8080 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 8080. Research CVE-2024-23897.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.23.10 --port 8080
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Jenkins credential decryption
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
