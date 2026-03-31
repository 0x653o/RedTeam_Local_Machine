# Machine 35: goanywher

| Field | Value |
|-------|-------|
| **CVE** | CVE-2023-0669 |
| **CVSS** | 9.8 |
| **Category** | 06 Data FileTransfer |
| **Difficulty** | Hard |
| **Points** | 50 |
| **IP** | 10.10.35.10 |
| **Port** | 8000 |

## Description
GoAnywhere MFT AES deserialization RCE

## Kill Chain
```
nmap -> GoAnywhere 8000 -> License portal -> AES deser -> blind deser -> RCE -> root
```

## MITRE ATT&CK
T1190,T1059.004

## Privilege Escalation
Java deserialization

<details><summary>Hint 1</summary>Start with nmap. What's on port 8000?</details>
<details><summary>Hint 2</summary>Research CVE-2023-0669.</details>
<details><summary>Hint 3</summary>Java deserialization</details>
