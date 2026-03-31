# Machine 05: shellshocked -- CVE-2014-6271 Walkthrough

## Overview
- **CVE**: CVE-2014-6271 (CVSS 10.0)
- **Kill Chain**: nmap -> Apache CGI 80 -> Shellshock User-Agent -> Shell -> SUID nmap interactive -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.5.10
# Port 80 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 80. Research CVE-2014-6271.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.5.10 --port 80
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: SUID nmap --interactive
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
