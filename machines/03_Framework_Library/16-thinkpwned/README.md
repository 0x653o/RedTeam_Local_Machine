# Machine 16: thinkpwned

| Field | Value |
|-------|-------|
| **CVE** | CVE-2018-20062 |
| **CVSS** | 9.8 |
| **Category** | 03 Framework Library |
| **Difficulty** | Easy |
| **Points** | 10 |
| **IP** | 10.10.16.10 |
| **Port** | 80 |

## Description
ThinkPHP invokefunction RCE with SUID find

## Kill Chain
```
nmap -> ThinkPHP 80 -> invokefunction controller -> RCE -> SUID find -> find -exec sh -> root
```

## MITRE ATT&CK
T1190,T1548.001

## Privilege Escalation
SUID find binary

<details><summary>Hint 1</summary>Start with nmap. What's on port 80?</details>
<details><summary>Hint 2</summary>Research CVE-2018-20062.</details>
<details><summary>Hint 3</summary>SUID find binary</details>
