# Machine 21: weblogicbmb -- CVE-2019-2725 Walkthrough

## Overview
- **CVE**: CVE-2019-2725 (CVSS 9.8)
- **Kill Chain**: nmap -> WebLogic 7001 -> T3/IIOP -> XMLDecoder /_async -> RCE -> already root in container -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.21.10
# Port 7001 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 7001. Research CVE-2019-2725.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.21.10 --port 7001
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Container runs as root
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
