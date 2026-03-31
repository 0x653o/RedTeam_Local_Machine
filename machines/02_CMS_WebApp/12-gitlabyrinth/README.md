# Machine 12: gitlabyrinth

| Field | Value |
|-------|-------|
| **CVE** | CVE-2021-22205 |
| **CVSS** | 10.0 |
| **Category** | 02 CMS WebApp |
| **Difficulty** | Hard |
| **Points** | 50 |
| **IP** | 10.10.12.10 |
| **Port** | 80 |

## Description
GitLab ExifTool RCE into Rails console root SSH key

## Kill Chain
```
nmap -> GitLab 80 -> DjVu ExifTool upload -> RCE as git -> Rails console reset -> root SSH key repo -> root
```

## MITRE ATT&CK
T1190,T1059.004

## Privilege Escalation
GitLab Rails console

<details><summary>Hint 1</summary>Start with nmap. What's on port 80?</details>
<details><summary>Hint 2</summary>Research CVE-2021-22205.</details>
<details><summary>Hint 3</summary>GitLab Rails console</details>
