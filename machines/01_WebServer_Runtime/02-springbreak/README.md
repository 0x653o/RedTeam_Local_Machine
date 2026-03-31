# 🏴 Machine 02: SpringBreak

| Field | Value |
|-------|-------|
| **CVE** | CVE-2022-22965 |
| **CVSS** | 🔴 9.8 |
| **Category** | Web Server & Runtime |
| **Difficulty** | ⭐⭐ Medium |
| **Points** | 25 |
| **IP** | 10.10.2.10 |

## Kill Chain
```
nmap → Spring Boot 8080 → /actuator endpoint → Class loader RCE → JSP webshell → Writable cron script → root
```

## MITRE ATT&CK
T1190, T1505.003, T1053.003

<details><summary>Hint 1</summary>Spring Boot exposes management endpoints by default.</details>
<details><summary>Hint 2</summary>The class loader can be manipulated via GET/POST parameters to write files.</details>
<details><summary>Hint 3</summary>Check what cron jobs run as root and whether their scripts are writable.</details>
