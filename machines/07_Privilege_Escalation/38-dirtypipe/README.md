# Machine 38: dirtypipe

| Field | Value |
|-------|-------|
| **CVE** | CVE-2022-0847 |
| **CVSS** | 7.8 |
| **Category** | 07 Privilege Escalation |
| **Difficulty** | Hard |
| **Points** | 50 |
| **IP** | 10.10.38.10 |
| **Port** | 80 |

## Description
SSRF internal SSTI kernel splice pipe exploit

## Kill Chain
```
nmap -> SSRF 80 -> internal webapp -> SSTI -> low shell -> /etc/passwd overwrite via splice -> root
```

## MITRE ATT&CK
T1190,T1090,T1068

## Privilege Escalation
Kernel splice pipe bug

<details><summary>Hint 1</summary>Start with nmap. What's on port 80?</details>
<details><summary>Hint 2</summary>Research CVE-2022-0847.</details>
<details><summary>Hint 3</summary>Kernel splice pipe bug</details>
