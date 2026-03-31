# Machine 24: activemqtter

| Field | Value |
|-------|-------|
| **CVE** | CVE-2023-46604 |
| **CVSS** | 10.0 |
| **Category** | 04 Enterprise Middleware |
| **Difficulty** | Medium |
| **Points** | 25 |
| **IP** | 10.10.24.10 |
| **Port** | 8161 |

## Description
ActiveMQ ClassInfo deserialization sudo escape

## Kill Chain
```
nmap -> ActiveMQ 61616+8161 -> ClassInfo ExceptionResponse deser -> RCE -> sudo escape -> root
```

## MITRE ATT&CK
T1190,T1548.003

## Privilege Escalation
Service account sudo

<details><summary>Hint 1</summary>Start with nmap. What's on port 8161?</details>
<details><summary>Hint 2</summary>Research CVE-2023-46604.</details>
<details><summary>Hint 3</summary>Service account sudo</details>
