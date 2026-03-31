# 🏴 Machine 01: Log4Hell

## Overview

| Field | Value |
|-------|-------|
| **CVE** | [CVE-2021-44228](https://nvd.nist.gov/vuln/detail/CVE-2021-44228) |
| **CVSS** | 🔴 10.0 (Critical) |
| **Category** | Web Server & Runtime |
| **Difficulty** | ⭐⭐ Medium |
| **Points** | 25 |
| **OS** | Linux (Ubuntu 22.04) |
| **IP** | 10.10.1.10 |
| **Ports** | 8080 (HTTP) |

## Description

A corporate internal dashboard is running on this machine. The application appears to be built with Java and uses a popular logging framework. Your mission is to gain initial access, escalate privileges, and capture both flags.

## Kill Chain

```
RECON → ENUMERATE → EXPLOIT → POST-EXPLOIT
 nmap     Log4j       JNDI      SUID binary
          version     injection  → root flag
```

## MITRE ATT&CK Mapping

| Phase | Technique |
|-------|-----------|
| Initial Access | T1190 — Exploit Public-Facing Application |
| Execution | T1059.004 — Unix Shell |
| Privilege Escalation | T1548.001 — Setuid/Setgid |

## Hints

<details>
<summary>Hint 1 (Recon)</summary>
What version of Java frameworks might log HTTP headers?
</details>

<details>
<summary>Hint 2 (Exploit)</summary>
The application logs more than just the request path. Check ALL request headers.
</details>

<details>
<summary>Hint 3 (Priv Esc)</summary>
Look for unusual SUID binaries. Not every `find / -perm -u=s` result is standard.
</details>

## Flags

| Flag | Location | Points |
|------|----------|--------|
| User | `/home/user/user.txt` | 10 |
| Root | `/root/root.txt` | 15 |
