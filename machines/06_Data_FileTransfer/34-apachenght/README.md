# Machine 34: apachenght

| Field | Value |
|-------|-------|
| **CVE** | CVE-2023-25690 |
| **CVSS** | 9.8 |
| **Category** | 06 Data FileTransfer |
| **Difficulty** | Hard |
| **Points** | 50 |
| **IP** | 10.10.34.10 |
| **Port** | 80 |

## Description
Apache reverse proxy HTTP request smuggling

## Kill Chain
```
nmap -> Apache proxy 80 -> request smuggling -> bypass auth -> management API -> RCE -> root
```

## MITRE ATT&CK
T1190,T1036.005

## Privilege Escalation
Request smuggling

<details><summary>Hint 1</summary>Start with nmap. What's on port 80?</details>
<details><summary>Hint 2</summary>Research CVE-2023-25690.</details>
<details><summary>Hint 3</summary>Request smuggling</details>
