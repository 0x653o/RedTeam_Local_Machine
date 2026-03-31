# Machine 13: grafanleak

| Field | Value |
|-------|-------|
| **CVE** | CVE-2021-43798 |
| **CVSS** | 7.5 |
| **Category** | 02 CMS WebApp |
| **Difficulty** | Easy |
| **Points** | 10 |
| **IP** | 10.10.13.10 |
| **Port** | 3000 |

## Description
Grafana path traversal into SQLite cred leak SSH spray

## Kill Chain
```
nmap -> Grafana 3000 -> plugin path traversal -> read config -> SQLite download -> extract creds -> SSH -> root
```

## MITRE ATT&CK
T1190,T1552.001,T1021.004

## Privilege Escalation
Credential spray via SSH

<details><summary>Hint 1</summary>Start with nmap. What's on port 3000?</details>
<details><summary>Hint 2</summary>Research CVE-2021-43798.</details>
<details><summary>Hint 3</summary>Credential spray via SSH</details>
