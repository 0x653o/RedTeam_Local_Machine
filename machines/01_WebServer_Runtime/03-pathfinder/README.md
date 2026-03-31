# 🏴 Machine 03: PathFinder
| Field | Value |
|-------|-------|
| **CVE** | CVE-2021-41773 |
| **CVSS** | 🔴 9.8 |
| **Category** | Web Server & Runtime |
| **Difficulty** | ⭐ Easy |
| **Points** | 10 |
| **IP** | 10.10.3.10 |
## Kill Chain
```
nmap → Apache 2.4.49 on 80 → Path traversal /%2e%2e/ → CGI RCE → Low shell → Kernel exploit → root
```
## MITRE ATT&CK: T1190, T1068
<details><summary>Hint 1</summary>Apache 2.4.49 has a specific path traversal bug. Try URL-encoded dots.</details>
<details><summary>Hint 2</summary>Can you reach /etc/passwd through the web server?</details>
<details><summary>Hint 3</summary>If CGI is enabled, path traversal becomes RCE.</details>
