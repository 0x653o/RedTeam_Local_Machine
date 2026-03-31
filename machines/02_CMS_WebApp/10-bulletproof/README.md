# Machine 10: bulletproof

| Field | Value |
|-------|-------|
| **CVE** | CVE-2019-16759 |
| **CVSS** | 9.8 |
| **Category** | 02 CMS WebApp |
| **Difficulty** | Medium |
| **Points** | 25 |
| **IP** | 10.10.10.10 |
| **Port** | 80 |

## Description
vBulletin widgetConfig pre-auth RCE into hidden cronjob

## Kill Chain
```
nmap -> vBulletin 80 -> widgetConfig RCE -> discover hidden cronjob -> write cron path -> root
```

## MITRE ATT&CK
T1190,T1053.003

## Privilege Escalation
Hidden cronjob hijack

<details><summary>Hint 1</summary>Start with nmap. What's on port 80?</details>
<details><summary>Hint 2</summary>Research CVE-2019-16759.</details>
<details><summary>Hint 3</summary>Hidden cronjob hijack</details>
