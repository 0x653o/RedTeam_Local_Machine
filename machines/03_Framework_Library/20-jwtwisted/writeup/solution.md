# Machine 20: jwtwisted -- CVE-2022-21449 Walkthrough

## Overview
- **CVE**: CVE-2022-21449 (CVSS 9.8)
- **Kill Chain**: nmap -> Java API 8080 -> capture JWT -> algorithm confusion -> forge admin -> SSRF -> internal service -> RCE -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.20.10
# Port 8080 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 8080. Research CVE-2022-21449.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.20.10 --port 8080
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: SSRF to internal service
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
