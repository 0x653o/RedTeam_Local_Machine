# Machine 36: baronsamedit

| Field | Value |
|-------|-------|
| **CVE** | CVE-2021-3156 |
| **CVSS** | 7.8 |
| **Category** | 07 Privilege Escalation |
| **Difficulty** | Hard |
| **Points** | 50 |
| **IP** | 10.10.36.10 |
| **Port** | 80 |

## Description
PHP upload webshell sudo heap overflow

## Kill Chain
```
nmap -> PHP upload 80 -> webshell -> low shell -> sudo 1.8.x -> heap overflow sudoedit -s -> root
```

## MITRE ATT&CK
T1190,T1068

## Privilege Escalation
sudo heap buffer overflow

<details><summary>Hint 1</summary>Start with nmap. What's on port 80?</details>
<details><summary>Hint 2</summary>Research CVE-2021-3156.</details>
<details><summary>Hint 3</summary>sudo heap buffer overflow</details>
