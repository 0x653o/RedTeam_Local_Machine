# Machine 32: minioleaker

| Field | Value |
|-------|-------|
| **CVE** | CVE-2023-28432 |
| **CVSS** | 9.8 |
| **Category** | 05 NetworkAppliance Proxy |
| **Difficulty** | Easy |
| **Points** | 10 |
| **IP** | 10.10.32.10 |
| **Port** | 9000 |

## Description
MinIO env var leak S3 keys SSH key in bucket

## Kill Chain
```
nmap -> MinIO 9000 -> /minio/health/cluster env leak -> S3 keys -> SSH key in bucket -> SSH -> root
```

## MITRE ATT&CK
T1190,T1552.001,T1021.004

## Privilege Escalation
S3 bucket credential leak

<details><summary>Hint 1</summary>Start with nmap. What's on port 9000?</details>
<details><summary>Hint 2</summary>Research CVE-2023-28432.</details>
<details><summary>Hint 3</summary>S3 bucket credential leak</details>
