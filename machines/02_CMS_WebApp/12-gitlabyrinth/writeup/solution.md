# Machine 12: gitlabyrinth -- CVE-2021-22205 Walkthrough

## Overview
- **CVE**: CVE-2021-22205 (CVSS 10.0)
- **Kill Chain**: nmap -> GitLab 80 -> DjVu ExifTool upload -> RCE as git -> Rails console reset -> root SSH key repo -> root

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.12.10
# Port 80 open
```

## Step 2: Enumeration
Identify the vulnerable service on port 80. Research CVE-2021-22205.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.12.10 --port 80
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: GitLab Rails console
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
