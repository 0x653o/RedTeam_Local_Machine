# Machine 19: picklerick

| Field | Value |
|-------|-------|
| **CVE** | CWE-502 |
| **CVSS** | 9.8 |
| **Category** | 03 Framework Library |
| **Difficulty** | Hard |
| **Points** | 50 |
| **IP** | 10.10.19.10 |
| **Port** | 5000 |

## Description
Python pickle deserialization Redis pivot SSH key

## Kill Chain
```
nmap -> Python 5000 -> decode session cookie -> pickle format -> malicious pickle -> RCE -> Redis -> SSH key -> root
```

## MITRE ATT&CK
T1190,T1021.006

## Privilege Escalation
Redis lateral movement

<details><summary>Hint 1</summary>Start with nmap. What's on port 5000?</details>
<details><summary>Hint 2</summary>Research CWE-502.</details>
<details><summary>Hint 3</summary>Redis lateral movement</details>
