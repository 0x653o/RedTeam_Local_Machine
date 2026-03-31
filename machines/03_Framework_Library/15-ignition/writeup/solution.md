# Machine 15: ignition -- CVE-2021-3129 Walkthrough

## Overview
- **CVE**: CVE-2021-3129 (CVSS 9.8)
- **Kill Chain**: gobuster -> Laravel debug -> Ignition execute-solution -> phar file write -> RCE -> root SSH key /opt -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.15.10
# Port 80 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 80. Research CVE-2021-3129.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.15.10 --port 80
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: SSH key discovery
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
