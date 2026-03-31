# Machine 30: citrixbreaker

| Field | Value |
|-------|-------|
| **CVE** | CVE-2019-19781 |
| **CVSS** | 9.8 |
| **Category** | 05 NetworkAppliance Proxy |
| **Difficulty** | Hard |
| **Points** | 50 |
| **IP** | 10.10.30.10 |
| **Port** | 443 |

## Description
Citrix ADC path traversal Perl template RCE

## Kill Chain
```
nmap -> Citrix 443 -> path traversal -> write Perl template -> trigger -> webshell -> RCE -> root
```

## MITRE ATT&CK
T1190,T1505.003

## Privilege Escalation
Template injection

<details><summary>Hint 1</summary>Start with nmap. What's on port 443?</details>
<details><summary>Hint 2</summary>Research CVE-2019-19781.</details>
<details><summary>Hint 3</summary>Template injection</details>
