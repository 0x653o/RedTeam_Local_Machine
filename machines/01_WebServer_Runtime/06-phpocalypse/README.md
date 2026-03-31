# Machine 06: phpocalypse

| Field | Value |
|-------|-------|
| **CVE** | CVE-2012-1823 |
| **CVSS** | 9.8 |
| **Category** | 01 WebServer Runtime |
| **Difficulty** | Easy |
| **Points** | 10 |
| **IP** | 10.10.6.10 |
| **Port** | 80 |

## Description
PHP-CGI argument injection into RCE via writable cron

## Kill Chain
```
nmap -> PHP-CGI 80 -> ?-s leaks source -> argument injection RCE -> writable cron -> root
```

## MITRE ATT&CK
T1190,T1053.003

## Privilege Escalation
Writable cron script

<details><summary>Hint 1</summary>Start with nmap. What's on port 80?</details>
<details><summary>Hint 2</summary>Research CVE-2012-1823.</details>
<details><summary>Hint 3</summary>Writable cron script</details>
