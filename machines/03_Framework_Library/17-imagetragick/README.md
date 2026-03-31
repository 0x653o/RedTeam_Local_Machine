# Machine 17: imagetragick

| Field | Value |
|-------|-------|
| **CVE** | CVE-2016-3714 |
| **CVSS** | 8.4 |
| **Category** | 03 Framework Library |
| **Difficulty** | Medium |
| **Points** | 25 |
| **IP** | 10.10.17.10 |
| **Port** | 80 |

## Description
ImageMagick MVG command injection cron root processing

## Kill Chain
```
nmap -> image upload 80 -> MVG file cmd injection -> shell -> cron ImageMagick root -> poison input -> root
```

## MITRE ATT&CK
T1190,T1053.003

## Privilege Escalation
Cron ImageMagick processing

<details><summary>Hint 1</summary>Start with nmap. What's on port 80?</details>
<details><summary>Hint 2</summary>Research CVE-2016-3714.</details>
<details><summary>Hint 3</summary>Cron ImageMagick processing</details>
