# Machine 28: solrblaze -- CVE-2019-17558 Walkthrough

## Overview
- **CVE**: CVE-2019-17558 (CVSS 9.8)
- **Kill Chain**: nmap -> Solr 8983 -> Velocity template injection -> RCE -> SSH creds in logs -> SSH root -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.28.10
# Port 8983 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 8983. Research CVE-2019-17558.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.28.10 --port 8983
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Log credential leak
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
