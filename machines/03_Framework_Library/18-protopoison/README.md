# Machine 18: protopoison

| Field | Value |
|-------|-------|
| **CVE** | CWE-1321 |
| **CVSS** | 9.8 |
| **Category** | 03 Framework Library |
| **Difficulty** | Hard |
| **Points** | 50 |
| **IP** | 10.10.18.10 |
| **Port** | 3000 |

## Description
Node.js prototype pollution into EJS SSTI RCE

## Kill Chain
```
nmap -> Node.js API 3000 -> fuzz JSON -> __proto__ pollution -> EJS template options -> SSTI -> RCE -> root
```

## MITRE ATT&CK
T1190,T1059.007

## Privilege Escalation
Container runs as root

<details><summary>Hint 1</summary>Start with nmap. What's on port 3000?</details>
<details><summary>Hint 2</summary>Research CWE-1321.</details>
<details><summary>Hint 3</summary>Container runs as root</details>
