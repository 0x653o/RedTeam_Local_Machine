# Machine 22: react2shell

| Field | Value |
|-------|-------|
| **CVE** | CVE-2025-55182 |
| **CVSS** | 10.0 |
| **Category** | 03 Framework Library |
| **Difficulty** | Insane |
| **Points** | 100 |
| **IP** | 10.10.22.10 |
| **Port** | 3000 |

## Description
Next.js RSC Flight protocol deserialization env pivot PostgreSQL SSH

## Kill Chain
```
nmap -> Next.js 3000 -> RSC Flight endpoint -> crafted serialized payload -> RCE node -> process.env -> DB creds -> PostgreSQL SSH keys -> sudo miscfg -> root
```

## MITRE ATT&CK
T1190,T1059.007,T1021.004

## Privilege Escalation
Database credential pivot

<details><summary>Hint 1</summary>Start with nmap. What's on port 3000?</details>
<details><summary>Hint 2</summary>Research CVE-2025-55182.</details>
<details><summary>Hint 3</summary>Database credential pivot</details>
