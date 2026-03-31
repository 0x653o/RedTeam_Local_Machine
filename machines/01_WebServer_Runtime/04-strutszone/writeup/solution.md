# Machine 04: strutszone -- CVE-2017-5638 Walkthrough

## Overview
- **CVE**: CVE-2017-5638 (CVSS 10.0)
- **Kill Chain**: nmap -> Struts2 8080 -> OGNL Content-Type injection -> RCE as tomcat -> sudo miscfg -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.4.10
# Port 8080 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 8080. Research CVE-2017-5638.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.4.10 --port 8080
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Misconfigured sudo
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
