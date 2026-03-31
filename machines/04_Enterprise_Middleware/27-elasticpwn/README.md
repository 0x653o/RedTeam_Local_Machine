# Machine 27: elasticpwn

| Field | Value |
|-------|-------|
| **CVE** | CVE-2015-1427 |
| **CVSS** | 9.8 |
| **Category** | 04 Enterprise Middleware |
| **Difficulty** | Medium |
| **Points** | 25 |
| **IP** | 10.10.27.10 |
| **Port** | 9200 |

## Description
Elasticsearch Groovy script sandbox escape

## Kill Chain
```
nmap -> ES 9200 -> Groovy script _search -> sandbox escape -> RCE -> config cred reuse -> root
```

## MITRE ATT&CK
T1190,T1552.001

## Privilege Escalation
Credential reuse

<details><summary>Hint 1</summary>Start with nmap. What's on port 9200?</details>
<details><summary>Hint 2</summary>Research CVE-2015-1427.</details>
<details><summary>Hint 3</summary>Credential reuse</details>
