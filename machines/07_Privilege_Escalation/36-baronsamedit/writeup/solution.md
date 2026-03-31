# Machine 36: baronsamedit -- CVE-2021-3156 Walkthrough

## Overview
- **CVE**: CVE-2021-3156 (CVSS 7.8)
- **Kill Chain**: nmap -> PHP upload 80 -> webshell -> low shell -> sudo 1.8.x -> heap overflow sudoedit -s -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.36.10
# Port 80 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 80. Research CVE-2021-3156.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.36.10 --port 80
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: sudo heap buffer overflow
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
