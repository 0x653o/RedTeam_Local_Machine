# Machine 24: activemqtter -- CVE-2023-46604 Walkthrough

## Overview
- **CVE**: CVE-2023-46604 (CVSS 10.0)
- **Kill Chain**: nmap -> ActiveMQ 61616+8161 -> ClassInfo ExceptionResponse deser -> RCE -> sudo escape -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.24.10
# Port 8161 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 8161. Research CVE-2023-46604.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.24.10 --port 8161
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Service account sudo
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
