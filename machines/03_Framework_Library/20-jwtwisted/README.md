# Machine 20: jwtwisted

| Field | Value |
|-------|-------|
| **CVE** | CVE-2022-21449 |
| **CVSS** | 9.8 |
| **Category** | 03 Framework Library |
| **Difficulty** | Hard |
| **Points** | 50 |
| **IP** | 10.10.20.10 |
| **Port** | 8080 |

## Description
Java JWT algorithm confusion admin SSRF internal RCE

## Kill Chain
```
nmap -> Java API 8080 -> capture JWT -> algorithm confusion -> forge admin -> SSRF -> internal service -> RCE -> root
```

## MITRE ATT&CK
T1190,T1550.001,T1090

## Privilege Escalation
SSRF to internal service

<details><summary>Hint 1</summary>Start with nmap. What's on port 8080?</details>
<details><summary>Hint 2</summary>Research CVE-2022-21449.</details>
<details><summary>Hint 3</summary>SSRF to internal service</details>
