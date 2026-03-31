# Machine 29: bigipwned

| Field | Value |
|-------|-------|
| **CVE** | CVE-2022-1388 |
| **CVSS** | 9.8 |
| **Category** | 05 NetworkAppliance Proxy |
| **Difficulty** | Medium |
| **Points** | 25 |
| **IP** | 10.10.29.10 |
| **Port** | 443 |

## Description
F5 BIG-IP header auth bypass iControl REST RCE

## Kill Chain
```
nmap -> BIG-IP 443 -> header auth bypass -> iControl REST -> RCE -> already root -> root
```

## MITRE ATT&CK
T1190,T1071.001

## Privilege Escalation
Already root in appliance

<details><summary>Hint 1</summary>Start with nmap. What's on port 443?</details>
<details><summary>Hint 2</summary>Research CVE-2022-1388.</details>
<details><summary>Hint 3</summary>Already root in appliance</details>
