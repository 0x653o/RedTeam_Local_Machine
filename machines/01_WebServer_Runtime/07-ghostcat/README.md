# Machine 07: ghostcat

| Field | Value |
|-------|-------|
| **CVE** | CVE-2020-1938 |
| **CVSS** | 9.8 |
| **Category** | 01 WebServer Runtime |
| **Difficulty** | Medium |
| **Points** | 25 |
| **IP** | 10.10.7.10 |
| **Port** | 8080 |

## Description
Tomcat AJP Ghostcat file read into Manager WAR deploy

## Kill Chain
```
nmap -> AJP 8009 + HTTP 8080 -> Ghostcat WEB-INF read -> admin creds -> WAR deploy -> root
```

## MITRE ATT&CK
T1190,T1552.001

## Privilege Escalation
WAR shell deployment

<details><summary>Hint 1</summary>Start with nmap. What's on port 8080?</details>
<details><summary>Hint 2</summary>Research CVE-2020-1938.</details>
<details><summary>Hint 3</summary>WAR shell deployment</details>
