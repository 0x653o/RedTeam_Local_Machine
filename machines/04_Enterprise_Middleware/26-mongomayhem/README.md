# Machine 26: mongomayhem

| Field | Value |
|-------|-------|
| **CVE** | Miscfg+NoSQLi |
| **CVSS** | 9.1 |
| **Category** | 04 Enterprise Middleware |
| **Difficulty** | Medium |
| **Points** | 25 |
| **IP** | 10.10.26.10 |
| **Port** | 80 |

## Description
MongoDB no auth webapp admin creds NoSQLi RCE

## Kill Chain
```
nmap -> MongoDB 27017 + webapp 80 -> dump users collection -> admin creds -> NoSQLi admin -> RCE -> root
```

## MITRE ATT&CK
T1190,T1552.001,T1550.001

## Privilege Escalation
NoSQLi command injection

<details><summary>Hint 1</summary>Start with nmap. What's on port 80?</details>
<details><summary>Hint 2</summary>Research Miscfg+NoSQLi.</details>
<details><summary>Hint 3</summary>NoSQLi command injection</details>
