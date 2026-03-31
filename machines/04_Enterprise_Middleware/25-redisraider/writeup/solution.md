# Machine 25: redisraider -- Miscfg Walkthrough

## Overview
- **CVE**: Miscfg (CVSS 9.8)
- **Kill Chain**: nmap -> Redis 6379 no auth -> CONFIG SET dir /root/.ssh -> write authorized_keys -> SSH root -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.25.10
# Port 6379 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 6379. Research Miscfg.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.25.10 --port 6379
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: Redis SSH key write
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
