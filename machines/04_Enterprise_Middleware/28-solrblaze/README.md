# Machine 28: solrblaze

| Field | Value |
|-------|-------|
| **CVE** | CVE-2019-17558 |
| **CVSS** | 9.8 |
| **Category** | 04 Enterprise Middleware |
| **Difficulty** | Medium |
| **Points** | 25 |
| **IP** | 10.10.28.10 |
| **Port** | 8983 |

## Description
Solr Velocity template injection

## Kill Chain
```
nmap -> Solr 8983 -> Velocity template injection -> RCE -> SSH creds in logs -> SSH root -> root
```

## MITRE ATT&CK
T1190,T1552.001,T1021.004

## Privilege Escalation
Log credential leak

<details><summary>Hint 1</summary>Start with nmap. What's on port 8983?</details>
<details><summary>Hint 2</summary>Research CVE-2019-17558.</details>
<details><summary>Hint 3</summary>Log credential leak</details>
