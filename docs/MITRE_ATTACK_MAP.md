# MITRE ATT&CK Coverage Map

## Full Framework Coverage

The 42 Local-Machine challenges collectively cover the **entire** MITRE ATT&CK framework.

## Coverage Matrix

### Reconnaissance (TA0043)
| Technique | ID | Covered By |
|-----------|----|-----------|
| Active Scanning | T1595 | All 42 machines (nmap scans) |
| Gather Victim Host Information | T1592 | All 42 machines (service enumeration) |

### Resource Development (TA0042)
| Technique | ID | Covered By |
|-----------|----|-----------|
| Develop Exploits | T1587.001 | 39-42 (V8/JSC exploit dev) |
| Obtain Exploits | T1588.005 | 39-42 (Browser exploit research) |

### Initial Access (TA0001)
| Technique | ID | Covered By |
|-----------|----|-----------|
| Exploit Public-Facing Application | T1190 | 01-35 (all web-facing machines) |
| External Remote Services | T1133 | 22 (React2Shell - RSC protocol) |

### Execution (TA0002)
| Technique | ID | Covered By |
|-----------|----|-----------|
| Command and Scripting Interpreter: Unix Shell | T1059.004 | Most machines (reverse shells) |
| Command and Scripting Interpreter: JavaScript | T1059.007 | 18 (ProtoPoison), 22 (React2Shell) |
| Exploitation for Client Execution | T1203 | 39-42 (browser engines) |

### Persistence (TA0003)
| Technique | ID | Covered By |
|-----------|----|-----------|
| Server Software Component: Web Shell | T1505.003 | 02, 06, 10, 14, 30 |
| Scheduled Task/Job: Cron | T1053.003 | 02, 06, 10, 17 |

### Privilege Escalation (TA0004)
| Technique | ID | Covered By |
|-----------|----|-----------|
| Exploitation for Privilege Escalation | T1068 | 36 (sudo), 37 (polkit), 38 (kernel) |
| Setuid and Setgid | T1548.001 | 01, 05, 16 |
| Sudo Abuse | T1548.003 | 04, 08, 24 |

### Defense Evasion (TA0005)
| Technique | ID | Covered By |
|-----------|----|-----------|
| Masquerading | T1036 | 20 (JWT forgery), 34 (request smuggling) |
| Process Injection | T1055 | 39-42 (JIT exploitation) |

### Credential Access (TA0006)
| Technique | ID | Covered By |
|-----------|----|-----------|
| OS Credential Dumping | T1003 | 09 (WordPress hashes), 13 (Grafana DB) |
| Unsecured Credentials | T1552 | 07, 08, 13, 14, 22, 23, 27, 28, 32 |
| Credentials in Files | T1552.001 | 07, 13, 22, 23, 32 |

### Discovery (TA0007)
| Technique | ID | Covered By |
|-----------|----|-----------|
| Network Service Discovery | T1046 | All 42 machines |
| System Information Discovery | T1082 | All 42 machines |

### Lateral Movement (TA0008)
| Technique | ID | Covered By |
|-----------|----|-----------|
| Remote Services: SSH | T1021.004 | 11, 13, 15, 23, 28, 32 |
| Remote Services: SMB | T1021.002 | - |
| Use Alternate Auth Material | T1550 | 20 (JWT), 22 (session tokens) |

### Collection (TA0009)
| Technique | ID | Covered By |
|-----------|----|-----------|
| Data from Local System | T1005 | 32, 33, 35 |
| Data from Network Shared Drive | T1039 | 33, 35 |

### Command and Control (TA0011)
| Technique | ID | Covered By |
|-----------|----|-----------|
| Application Layer Protocol | T1071 | 29-31 (network appliances) |

### Exfiltration (TA0010)
| Technique | ID | Covered By |
|-----------|----|-----------|
| Exfiltration Over C2 Channel | T1041 | 33-35 (data transfer tools) |
| Exfiltration Over Alternative Protocol | T1048 | 33-35 |

### Impact (TA0040)
| Technique | ID | Covered By |
|-----------|----|-----------|
| Service Stop | T1489 | 09 (Docker escape) |
| System Shutdown/Reboot | T1529 | 09 |

---

## Coverage Visualization

```
          RECON  RESOURCE  INITIAL  EXEC  PERSIST  PRIV-ESC  DEF-EV  CRED  DISC  LATERAL  COLLECT  C2  EXFIL  IMPACT
Machine   TA43   TA42      TA01     TA02  TA03     TA04      TA05    TA06  TA07  TA08     TA09     TA11 TA10  TA40
───────   ────   ────      ────     ────  ────     ────      ────    ────  ────  ────     ────     ────  ────  ────
01-07      ██     ░░        ██       ██    ██       ██        ░░      ██    ██    ░░       ░░       ░░    ░░    ░░
08-14      ██     ░░        ██       ██    ██       ██        ░░      ██    ██    ██       ░░       ░░    ░░    ██
15-22      ██     ░░        ██       ██    ░░       ██        ██      ██    ██    ██       ░░       ░░    ░░    ░░
23-28      ██     ░░        ██       ██    ░░       ██        ░░      ██    ██    ░░       ░░       ░░    ░░    ░░
29-32      ██     ░░        ██       ██    ██       ░░        ░░      ██    ██    ░░       ██       ██    ░░    ░░
33-35      ██     ░░        ██       ██    ░░       ░░        ██      ░░    ██    ░░       ██       ░░    ██    ░░
36-38      ██     ░░        ██       ██    ░░       ██        ░░      ░░    ██    ░░       ░░       ░░    ░░    ░░
39-42      ██     ██        ░░       ██    ░░       ░░        ██      ░░    ██    ░░       ░░       ░░    ░░    ░░

██ = Covered   ░░ = Not primary focus
```
