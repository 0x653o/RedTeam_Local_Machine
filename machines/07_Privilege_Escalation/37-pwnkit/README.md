# Machine 37: pwnkit

| Field | Value |
|-------|-------|
| **CVE** | CVE-2021-4034 |
| **CVSS** | 7.8 |
| **Category** | 07 Privilege Escalation |
| **Difficulty** | Medium |
| **Points** | 25 |
| **IP** | 10.10.37.10 |
| **Port** | 5000 |

## Description
Python webapp SSTI polkit pkexec exploit

## Kill Chain
```
nmap -> Python 5000 -> Jinja2 SSTI -> low shell -> polkit pkexec env var injection -> root
```

## MITRE ATT&CK
T1190,T1068

## Privilege Escalation
pkexec env variable injection

<details><summary>Hint 1</summary>Start with nmap. What's on port 5000?</details>
<details><summary>Hint 2</summary>Research CVE-2021-4034.</details>
<details><summary>Hint 3</summary>pkexec env variable injection</details>
