# Machine 23: jenkinsowned

| Field | Value |
|-------|-------|
| **CVE** | CVE-2024-23897 |
| **CVSS** | 9.8 |
| **Category** | 04 Enterprise Middleware |
| **Difficulty** | Hard |
| **Points** | 50 |
| **IP** | 10.10.23.10 |
| **Port** | 8080 |

## Description
Jenkins CLI file read decrypt SSH credentials

## Kill Chain
```
nmap -> Jenkins 8080 -> CLI argument file read -> leak master.key -> decrypt SSH creds -> SSH root -> root
```

## MITRE ATT&CK
T1190,T1552.004,T1021.004

## Privilege Escalation
Jenkins credential decryption

<details><summary>Hint 1</summary>Start with nmap. What's on port 8080?</details>
<details><summary>Hint 2</summary>Research CVE-2024-23897.</details>
<details><summary>Hint 3</summary>Jenkins credential decryption</details>
