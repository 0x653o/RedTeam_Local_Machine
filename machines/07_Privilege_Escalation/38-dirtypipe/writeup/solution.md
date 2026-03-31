# Machine 38: dirtypipe -- CVE-2022-0847 Walkthrough

## Overview
- **CVE**: CVE-2022-0847 (CVSS 7.8)
- **Kill Chain**: nmap -> SSRF 80 -> internal webapp -> SSTI -> low shell -> /etc/passwd overwrite via splice -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.38.10
# Port 80 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 80. Research CVE-2022-0847.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.38.10 --port 80
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Kernel splice pipe bug
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
