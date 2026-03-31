# Machine 32: minioleaker -- CVE-2023-28432 Walkthrough

## Overview
- **CVE**: CVE-2023-28432 (CVSS 9.8)
- **Kill Chain**: nmap -> MinIO 9000 -> /minio/health/cluster env leak -> S3 keys -> SSH key in bucket -> SSH -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.32.10
# Port 9000 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 9000. Research CVE-2023-28432.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.32.10 --port 9000
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: S3 bucket credential leak
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
