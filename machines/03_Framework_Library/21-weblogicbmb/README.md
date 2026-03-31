# Machine 21: weblogicbmb

| Field | Value |
|-------|-------|
| **CVE** | CVE-2019-2725 |
| **CVSS** | 9.8 |
| **Category** | 03 Framework Library |
| **Difficulty** | Medium |
| **Points** | 25 |
| **IP** | 10.10.21.10 |
| **Port** | 7001 |

## Description
WebLogic XMLDecoder deserialization already root

## Kill Chain
```
nmap -> WebLogic 7001 -> T3/IIOP -> XMLDecoder /_async -> RCE -> already root in container -> root
```

## MITRE ATT&CK
T1190,T1059.004

## Privilege Escalation
Container runs as root

<details><summary>Hint 1</summary>Start with nmap. What's on port 7001?</details>
<details><summary>Hint 2</summary>Research CVE-2019-2725.</details>
<details><summary>Hint 3</summary>Container runs as root</details>
