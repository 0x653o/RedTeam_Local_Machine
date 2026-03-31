# Machine 30: citrixbreaker -- CVE-2019-19781 Walkthrough

## Overview
- **CVE**: CVE-2019-19781 (CVSS 9.8)
- **Kill Chain**: nmap -> Citrix 443 -> path traversal -> write Perl template -> trigger -> webshell -> RCE -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.30.10
# Port 443 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 443. Research CVE-2019-19781.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.30.10 --port 443
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Template injection
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
