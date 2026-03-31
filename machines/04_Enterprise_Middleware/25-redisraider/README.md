# Machine 25: redisraider

| Field | Value |
|-------|-------|
| **CVE** | Miscfg |
| **CVSS** | 9.8 |
| **Category** | 04 Enterprise Middleware |
| **Difficulty** | Easy |
| **Points** | 10 |
| **IP** | 10.10.25.10 |
| **Port** | 6379 |

## Description
Redis no auth SSH key write

## Kill Chain
```
nmap -> Redis 6379 no auth -> CONFIG SET dir /root/.ssh -> write authorized_keys -> SSH root -> root
```

## MITRE ATT&CK
T1190,T1098.004,T1053.003

## Privilege Escalation
Redis SSH key write

<details><summary>Hint 1</summary>Start with nmap. What's on port 6379?</details>
<details><summary>Hint 2</summary>Research Miscfg.</details>
<details><summary>Hint 3</summary>Redis SSH key write</details>
