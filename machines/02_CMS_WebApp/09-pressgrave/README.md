# Machine 09: pressgrave

| Field | Value |
|-------|-------|
| **CVE** | CVE-2022-0739 |
| **CVSS** | 9.8 |
| **Category** | 02 CMS WebApp |
| **Difficulty** | Hard |
| **Points** | 50 |
| **IP** | 10.10.9.10 |
| **Port** | 80 |

## Description
WordPress SQLi into theme editor RCE and Docker socket escape

## Kill Chain
```
wpscan -> WordPress 80 -> Plugin SQLi -> hash dump -> theme editor RCE -> Docker socket escape -> host root
```

## MITRE ATT&CK
T1190,T1003.003,T1611

## Privilege Escalation
Docker socket escape

<details><summary>Hint 1</summary>Start with nmap. What's on port 80?</details>
<details><summary>Hint 2</summary>Research CVE-2022-0739.</details>
<details><summary>Hint 3</summary>Docker socket escape</details>
