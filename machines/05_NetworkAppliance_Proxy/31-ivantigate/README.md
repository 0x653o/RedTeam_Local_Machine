# Machine 31: ivantigate

| Field | Value |
|-------|-------|
| **CVE** | CVE-2024-21887 |
| **CVSS** | 9.1 |
| **Category** | 05 NetworkAppliance Proxy |
| **Difficulty** | Hard |
| **Points** | 50 |
| **IP** | 10.10.31.10 |
| **Port** | 443 |

## Description
Ivanti Connect Secure auth bypass cmd injection

## Kill Chain
```
nmap -> Ivanti 443 -> auth bypass chain -> command injection -> RCE -> already root -> root
```

## MITRE ATT&CK
T1190,T1059.004

## Privilege Escalation
Already root in appliance

<details><summary>Hint 1</summary>Start with nmap. What's on port 443?</details>
<details><summary>Hint 2</summary>Research CVE-2024-21887.</details>
<details><summary>Hint 3</summary>Already root in appliance</details>
