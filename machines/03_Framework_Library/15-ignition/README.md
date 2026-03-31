# Machine 15: ignition

| Field | Value |
|-------|-------|
| **CVE** | CVE-2021-3129 |
| **CVSS** | 9.8 |
| **Category** | 03 Framework Library |
| **Difficulty** | Medium |
| **Points** | 25 |
| **IP** | 10.10.15.10 |
| **Port** | 80 |

## Description
Laravel Ignition debug page phar file write RCE

## Kill Chain
```
gobuster -> Laravel debug -> Ignition execute-solution -> phar file write -> RCE -> root SSH key /opt -> root
```

## MITRE ATT&CK
T1190,T1021.004

## Privilege Escalation
SSH key discovery

<details><summary>Hint 1</summary>Start with nmap. What's on port 80?</details>
<details><summary>Hint 2</summary>Research CVE-2021-3129.</details>
<details><summary>Hint 3</summary>SSH key discovery</details>
