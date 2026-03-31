# Machine 19: picklerick -- CWE-502 Walkthrough

## Overview
- **CVE**: CWE-502 (CVSS 9.8)
- **Kill Chain**: nmap -> Python 5000 -> decode session cookie -> pickle format -> malicious pickle -> RCE -> Redis -> SSH key -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.19.10
# Port 5000 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 5000. Research CWE-502.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.19.10 --port 5000
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Redis lateral movement
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
