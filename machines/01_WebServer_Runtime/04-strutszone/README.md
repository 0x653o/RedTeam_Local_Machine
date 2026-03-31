# Machine 04: strutszone

| Field | Value |
|-------|-------|
| **CVE** | CVE-2017-5638 |
| **CVSS** | 10.0 |
| **Category** | 01 WebServer Runtime |
| **Difficulty** | Medium |
| **Points** | 25 |
| **IP** | 10.10.4.10 |
| **Port** | 8080 |

## Description
Apache Struts2 OGNL injection via Content-Type header

## Kill Chain
```
nmap -> Struts2 8080 -> OGNL Content-Type injection -> RCE as tomcat -> sudo miscfg -> root
```

## MITRE ATT&CK
T1190,T1059.004,T1548.003

## Privilege Escalation
Misconfigured sudo

<details><summary>Hint 1</summary>Start with nmap. What's on port 8080?</details>
<details><summary>Hint 2</summary>Research CVE-2017-5638.</details>
<details><summary>Hint 3</summary>Misconfigured sudo</details>
