# Machine 27: elasticpwn -- CVE-2015-1427 Walkthrough

## Overview
- **CVE**: CVE-2015-1427 (CVSS 9.8)
- **Kill Chain**: nmap -> ES 9200 -> Groovy script _search -> sandbox escape -> RCE -> config cred reuse -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.27.10
# Port 9200 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 9200. Research CVE-2015-1427.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.27.10 --port 9200
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Credential reuse
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
