# Machine 14: joombleed

| Field | Value |
|-------|-------|
| **CVE** | CVE-2023-23752 |
| **CVSS** | 7.5 |
| **Category** | 02 CMS WebApp |
| **Difficulty** | Easy |
| **Points** | 10 |
| **IP** | 10.10.14.10 |
| **Port** | 80 |

## Description
Joomla API info leak into DB creds template editor RCE

## Kill Chain
```
nmap -> Joomla 80 -> API info leak -> DB creds -> admin login -> template editor PHP -> sudo miscfg -> root
```

## MITRE ATT&CK
T1190,T1552.001,T1505.003

## Privilege Escalation
Sudo misconfiguration

<details><summary>Hint 1</summary>Start with nmap. What's on port 80?</details>
<details><summary>Hint 2</summary>Research CVE-2023-23752.</details>
<details><summary>Hint 3</summary>Sudo misconfiguration</details>
