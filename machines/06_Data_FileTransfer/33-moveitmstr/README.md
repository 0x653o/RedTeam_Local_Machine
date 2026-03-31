# Machine 33: moveitmstr

| Field | Value |
|-------|-------|
| **CVE** | CVE-2023-34362 |
| **CVSS** | 9.8 |
| **Category** | 06 Data FileTransfer |
| **Difficulty** | Hard |
| **Points** | 50 |
| **IP** | 10.10.33.10 |
| **Port** | 443 |

## Description
MOVEit Transfer SQLi session hijack deser RCE

## Kill Chain
```
nmap -> MOVEit 443 -> SQLi session handling -> extract tokens -> impersonate sysadmin -> deser RCE -> root
```

## MITRE ATT&CK
T1190,T1003.003

## Privilege Escalation
Deserialization chain

<details><summary>Hint 1</summary>Start with nmap. What's on port 443?</details>
<details><summary>Hint 2</summary>Research CVE-2023-34362.</details>
<details><summary>Hint 3</summary>Deserialization chain</details>
