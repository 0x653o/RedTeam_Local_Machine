# Machine 05: shellshocked

| Field | Value |
|-------|-------|
| **CVE** | CVE-2014-6271 |
| **CVSS** | 10.0 |
| **Category** | 01 WebServer Runtime |
| **Difficulty** | Easy |
| **Points** | 10 |
| **IP** | 10.10.5.10 |
| **Port** | 80 |

## Description
Bash Shellshock via CGI + SUID nmap

## Kill Chain
```
nmap -> Apache CGI 80 -> Shellshock User-Agent -> Shell -> SUID nmap interactive -> root
```

## MITRE ATT&CK
T1190,T1059.004,T1548.001

## Privilege Escalation
SUID nmap --interactive

<details><summary>Hint 1</summary>Start with nmap. What's on port 80?</details>
<details><summary>Hint 2</summary>Research CVE-2014-6271.</details>
<details><summary>Hint 3</summary>SUID nmap --interactive</details>
