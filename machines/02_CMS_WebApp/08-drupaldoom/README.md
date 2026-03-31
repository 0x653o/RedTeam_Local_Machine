# Machine 08: drupaldoom

| Field | Value |
|-------|-------|
| **CVE** | CVE-2018-7600 |
| **CVSS** | 9.8 |
| **Category** | 02 CMS WebApp |
| **Difficulty** | Medium |
| **Points** | 25 |
| **IP** | 10.10.8.10 |
| **Port** | 80 |

## Description
Drupalgeddon2 Form API RCE with MySQL cred reuse

## Kill Chain
```
nmap -> Drupal 80 -> Drupalgeddon2 RCE -> MySQL creds settings.php -> admin hash crack -> su sudo -> root
```

## MITRE ATT&CK
T1190,T1552.001,T1548.003

## Privilege Escalation
Credential reuse + sudo

<details><summary>Hint 1</summary>Start with nmap. What's on port 80?</details>
<details><summary>Hint 2</summary>Research CVE-2018-7600.</details>
<details><summary>Hint 3</summary>Credential reuse + sudo</details>
