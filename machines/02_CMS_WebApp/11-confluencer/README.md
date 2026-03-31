# Machine 11: confluencer

| Field | Value |
|-------|-------|
| **CVE** | CVE-2022-26134 |
| **CVSS** | 9.8 |
| **Category** | 02 CMS WebApp |
| **Difficulty** | Medium |
| **Points** | 25 |
| **IP** | 10.10.11.10 |
| **Port** | 8090 |

## Description
Confluence OGNL injection with SSH key reuse

## Kill Chain
```
nmap -> Confluence 8090 -> OGNL URL injection -> RCE -> SSH key in home -> key reuse for root -> root
```

## MITRE ATT&CK
T1190,T1021.004

## Privilege Escalation
SSH key reuse

<details><summary>Hint 1</summary>Start with nmap. What's on port 8090?</details>
<details><summary>Hint 2</summary>Research CVE-2022-26134.</details>
<details><summary>Hint 3</summary>SSH key reuse</details>
