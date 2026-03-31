# Machine 22: react2shell -- CVE-2025-55182 Walkthrough

## Overview
- **CVE**: CVE-2025-55182 (CVSS 10.0)
- **Kill Chain**: nmap -> Next.js 3000 -> RSC Flight endpoint -> crafted serialized payload -> RCE node -> process.env -> DB creds -> PostgreSQL SSH keys -> sudo miscfg -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.22.10
# Port 3000 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 3000. Research CVE-2025-55182.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.22.10 --port 3000
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Database credential pivot
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
