# Machine 16: thinkpwned -- CVE-2018-20062 Walkthrough

## Overview
- **CVE**: CVE-2018-20062 (CVSS 9.8)
- **Kill Chain**: nmap -> ThinkPHP 80 -> invokefunction controller -> RCE -> SUID find -> find -exec sh -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.16.10
# Port 80 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 80. Research CVE-2018-20062.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.16.10 --port 80
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: SUID find binary
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
