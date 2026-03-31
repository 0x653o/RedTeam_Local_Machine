# Machine 09: pressgrave -- CVE-2022-0739 Walkthrough

## Overview
- **CVE**: CVE-2022-0739 (CVSS 9.8)
- **Kill Chain**: wpscan -> WordPress 80 -> Plugin SQLi -> hash dump -> theme editor RCE -> Docker socket escape -> host root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.9.10
# Port 80 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 80. Research CVE-2022-0739.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.9.10 --port 80
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Docker socket escape
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
