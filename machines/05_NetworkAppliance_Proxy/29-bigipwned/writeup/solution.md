# Machine 29: bigipwned -- CVE-2022-1388 Walkthrough

## Overview
- **CVE**: CVE-2022-1388 (CVSS 9.8)
- **Kill Chain**: nmap -> BIG-IP 443 -> header auth bypass -> iControl REST -> RCE -> already root -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.29.10
# Port 443 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 443. Research CVE-2022-1388.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.29.10 --port 443
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Already root in appliance
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
