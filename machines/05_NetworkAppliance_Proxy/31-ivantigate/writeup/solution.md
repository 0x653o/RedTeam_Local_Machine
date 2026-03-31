# Machine 31: ivantigate -- CVE-2024-21887 Walkthrough

## Overview
- **CVE**: CVE-2024-21887 (CVSS 9.1)
- **Kill Chain**: nmap -> Ivanti 443 -> auth bypass chain -> command injection -> RCE -> already root -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.31.10
# Port 443 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 443. Research CVE-2024-21887.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.31.10 --port 443
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Already root in appliance
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
