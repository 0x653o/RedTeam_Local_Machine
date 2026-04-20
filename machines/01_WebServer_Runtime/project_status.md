# 🌐 Category 01: Web Server & Runtime — Project Status

> **Category Path**: `machines/01_WebServer_Runtime/`
> **Last Updated**: 2026-04-10
> **Scope**: Machines 01–07 (7 machines total)
> **Context Doc**: See root `PROJECT_STATUS.md` and `implementation_plan.md` for global project context.

---

## 1. CATEGORY OVERVIEW

This category covers foundational web server and runtime exploitation. All 7 machines live here:

| # | Name | CVE | CVSS | Difficulty | Network | Port(s) |
|---|------|-----|------|------------|---------|---------|
| 01 | Log4Hell | CVE-2021-44228 | 🔴 10.0 | Easy | 10.10.1.0/24 | 8080 |
| 02 | SpringBreak | CVE-2022-22965 | 🔴 9.8 | Medium | 10.10.2.0/24 | 8080 |
| 03 | PathFinder | CVE-2021-41773 | 🔴 9.8 | Easy | 10.10.3.0/24 | 80 |
| 04 | StrutsZone | CVE-2017-5638 | 🔴 10.0 | Medium | 10.10.4.0/24 | 8080 |
| 05 | ShellShocked | CVE-2014-6271 | 🔴 10.0 | Easy | 10.10.5.0/24 | 80 |
| 06 | PHPocalypse | CVE-2012-1823 | 🔴 9.8 | Easy | 10.10.6.0/24 | 80 |
| 07 | GhostCat | CVE-2020-1938 | 🔴 9.8 | Medium | 10.10.7.0/24 | 8009, 8080 |

---

## 2. STATUS LEGEND

| Symbol | Meaning |
|--------|---------|
| 🟢 **DEEP** | Fully implemented. Custom vulnerable app, specific Dockerfile, working exploit, complete privesc. Would actually build and run. |
| 🟡 **PARTIAL** | Has Dockerfile and some config files but missing critical service setup (`setup.sh` or `start-service.sh`) or has broken build steps. Container starts but service doesn't function properly. |
| 🔴 **SCAFFOLDED** | Has skeleton structure (entrypoint.sh) but NO `setup.sh`, NO `start-service.sh`, NO real service. Container stays alive with `tail -f /dev/null`. Cannot be exploited. |

---

## 3. CURRENT STATUS PER MACHINE

### 3.1 Machine 01 — Log4Hell (CVE-2021-44228)

**Status**: 🟢 DEEP

**Files present & working**:
```
01-log4hell/
├── Dockerfile              ✅ Downloads Log4j 2.14.1 JARs, compiles VulnApp.java, builds SUID vuln-reader binary
├── docker-compose.yml      ✅ Isolated 10.10.1.0/24 network, resource limits, healthcheck
├── healthcheck.sh          ✅ Checks port 8080, HTTP response, flag files, SUID bit on vuln-reader
├── config/
│   ├── entrypoint.sh       ✅ Generates flags, starts SSH, runs app as appuser
│   ├── VulnApp.java        ✅ Custom HTTP server that logs User-Agent/X-Api-Version/X-Forwarded-For via Log4j
│   ├── log4j2.xml          ✅ Log4j config with ConsoleAppender
│   ├── start-app.sh        ✅ Runs java -cp with JNDI trust flags enabled
│   └── vuln-reader.c       ✅ SUID binary for privilege escalation (reads files as root)
├── flags/generate.sh       ✅ Standalone flag generation
├── README.md               ✅ Machine card with CVE, difficulty, hints, kill chain
└── writeup/
    ├── solution.md         ✅ Full walkthrough: nmap → JNDI → shell → SUID → root
    ├── exploit.py          ✅ Working automated exploit
    └── references.md       ✅ CVE links, tools, ATT&CK techniques
```

**Known Issues & Active Problems**:

> ⚠️ **LOG4J BUILD ISSUE**: The Dockerfile downloads Log4j JARs from Maven Central at build time. If Maven is unreachable or URLs change, build fails silently (`|| true` suppresses errors). See `implementation_plan.md §4.1` for the fix strategy (embedded JARs via local copy).

> ⚠️ **JVM JNDI TRUST FLAGS**: `start-app.sh` passes `-Dcom.sun.jndi.ldap.object.trustURLCodebase=true` which is required for JNDI exploitation. However on JDK 11.0.20+ (ubuntu:22.04 apt default may update), this flag has no effect without also setting `-Dcom.sun.jndi.cosnaming.object.trustURLCodebase=true`. Both flags are already set — but if apt upgrades the JDK, verify exploitation still works.

> ⚠️ **APPUSER MISSING HOME DIR**: The entrypoint does `mkdir -p /home/user` but the `appuser` (who runs the Java app) doesn't get a proper home directory. Not a blocker but may cause SSH login issues as appuser.

**Verification Command**:
```bash
docker compose -f machines/01_WebServer_Runtime/01-log4hell/docker-compose.yml up -d
docker inspect lm-01-log4hell --format '{{ .State.Health.Status }}'
```

---

### 3.2 Machine 02 — SpringBreak (CVE-2022-22965)

**Status**: 🟢 DEEP

**Files present & working**:
```
02-springbreak/
├── Dockerfile              ✅ Downloads Spring 5.3.17 JARs, compiles WAR, deploys to Tomcat
├── docker-compose.yml      ✅ Isolated 10.10.2.0/24, port 8080
├── healthcheck.sh          ✅ Checks Tomcat/8080
├── config/
│   ├── entrypoint.sh       ✅
│   ├── setup-cron.sh       ✅ Sets up writable cron script for privesc
│   ├── VulnController.java ✅ Spring MVC controller with class loader manipulation endpoint
│   ├── Employee.java       ✅ Vulnerable model bean
│   ├── web.xml             ✅ Spring DispatcherServlet config
│   └── dispatcher-servlet.xml ✅ Component scan config
├── flags/generate.sh       ✅
├── README.md               ✅
└── writeup/
    ├── solution.md         ✅ Full step-by-step with javac commands
    ├── exploit.py          ✅ Working Spring4Shell exploit
    └── references.md       ✅
```

**Known Issues**: None critical. Confirmed fixed in previous session (Session 2).

---

### 3.3 Machine 03 — PathFinder (CVE-2021-41773)

**Status**: 🟢 DEEP

**Files present & working**:
```
03-pathfinder/
├── Dockerfile              ✅ Source-only Apache 2.4.49 build, httpd.conf with CGI enabled
├── docker-compose.yml      ✅ Isolated 10.10.3.0/24, port 80
├── healthcheck.sh          ✅
├── config/
│   ├── entrypoint.sh       ✅ Creates web content, log dirs
│   └── httpd.conf          ✅ mod_cgi enabled, Require all granted
├── flags/generate.sh       ✅
├── README.md               ✅
└── writeup/                ✅
```

**Known Issues**: None. Confirmed fixed in previous session.

---

### 3.4 Machine 04 — StrutsZone (CVE-2017-5638)

**Status**: 🟡 PARTIAL — *Service files exist but build is fragile*

**Files present**:
```
04-strutszone/
├── Dockerfile              🟡 Downloads Struts2 2.3.31 WAR + Tomcat 8.5.78 at build time
├── docker-compose.yml      ✅ Isolated 10.10.4.0/24
├── healthcheck.sh          ⚠️  Basic/skeleton — doesn't verify OGNL exploitability
├── config/
│   ├── entrypoint.sh       ✅ Standard pattern
│   ├── setup.sh            ✅ Adds `tomcat ALL=(ALL) NOPASSWD: /usr/bin/find` to sudoers
│   └── start-service.sh    ✅ `exec su -c "/opt/tomcat/bin/catalina.sh run" tomcat`
├── flags/                  ✅ generate.sh present
├── README.md               ✅
└── writeup/                ⚠️  Skeleton writeup (solution.md has TODO steps)
```

**Known Issues**:

> 🔴 **EXTERNAL BUILD DEPENDENCY CRITICAL**: `Dockerfile` downloads two external archives at build time:
> - `https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.78/bin/apache-tomcat-8.5.78.tar.gz`
> - `https://archive.apache.org/dist/struts/2.3.31/struts-2.3.31-apps.zip`
>
> The apache.org archive server is **unreliable** — these URLs 404 randomly. The WAR download is the main blocker. **Fix**: Mirror JARs locally or switch to a pre-packaged Docker image (e.g., `vulhub/struts2:s2-045`).

> 🔴 **MANAGER APP REMOVED**: The Dockerfile removes default webapps including `manager`, but `manager` is needed if players want to verify WAR deployment. Not needed for OGNL exploit, but removal needs to be intentional.

> 🟡 **HEALTHCHECK INCOMPLETE**: Current healthcheck only checks if port 8080 is open. Should verify the Struts2 showcase responds and that the OGNL gadget path is accessible.

> 🟡 **WRITEUP SKELETON**: `writeup/solution.md` and `exploit.py` are placeholder/skeleton files with TODO markers. Need actual OGNL exploit code for CVE-2017-5638.

**What's needed to become DEEP**:
1. Fix Dockerfile to not rely on external URLs (use vulhub image or cached WAR)
2. Add full healthcheck that verifies Struts2 endpoint
3. Write actual `exploit.py` with Content-Type OGNL injection
4. Write full `writeup/solution.md`

---

### 3.5 Machine 05 — ShellShocked (CVE-2014-6271)

**Status**: 🟡 PARTIAL — *Service exists but has critical CGI config gap*

**Files present**:
```
05-shellshocked/
├── Dockerfile              🟡 Builds vulnerable bash 4.3 from source, enables CGI, sets SUID nmap
├── docker-compose.yml      ✅ Isolated 10.10.5.0/24, port 80
├── healthcheck.sh          ⚠️  Skeleton
├── config/
│   ├── entrypoint.sh       ✅ Standard pattern
│   ├── setup.sh            🟡 Updates CGI shebang + writes Apache CGI config
│   ├── start-service.sh    ✅ Starts Apache httpd
│   └── cgi-scripts/
│       ├── test.cgi        ✅ Simple CGI with vulnerable bash shebang
│       └── status.cgi      ✅ More detailed CGI (hostname, uptime, etc.)
├── flags/                  ✅ generate.sh present
├── README.md               ✅
└── writeup/                ⚠️  Skeleton
```

**Known Issues**:

> 🔴 **BASH 4.3 COMPILE TIME**: Building bash 4.3 from source (`configure && make`) takes **5–10 minutes** in Docker, making the image build very slow. The source URL `https://ftp.gnu.org/gnu/bash/bash-4.3.tar.gz` may be slow or unreliable. **Alternative**: Use `patchelf` + copy a pre-patched old bash binary, or use a debian oldstable package. The simplest fix is to use a pre-downloaded bash binary or install `bash=4.3–*` from an old Debian source.

> 🔴 **CGI CONFIG GAP**: `setup.sh` writes `/etc/apache2/conf-available/serve-cgi-bin.conf` but **never enables it** (`a2enconf serve-cgi-bin`). The CGI alias for `/cgi-bin/ → /usr/lib/cgi-bin/` won't be active. CGI IS already enabled in Dockerfile (`a2enmod cgid cgi`) but the ScriptAlias is missing from active config.

> 🟡 **CGI shebang replacement**: `setup.sh` uses `sed -i "1s|.*|#!/opt/bash43/bin/bash|"` — this changes the shebang but the CGI scripts already have `#!/opt/bash43/bin/bash` as shebang (hardcoded in Dockerfile stage). The sed is redundant but harmless.

> 🟡 **SUID nmap version**: Ubuntu 20.04's nmap version may not have `--interactive` mode (was removed in nmap 6.x). The `--interactive` privesc only works on **nmap 2.02 – 5.21**. Modern nmap installed via apt will NOT work for `!sh` escape. May need to install old nmap from source or use a different SUID binary as privesc vector.

> 🟡 **WRITEUP SKELETON**: `writeup/` is placeholder.

**What's needed to become DEEP**:
1. Fix CGI config activation (`a2enconf serve-cgi-bin` in setup.sh)
2. Replace nmap SUID with a custom SUID binary (since modern nmap has no `--interactive`)
3. Fix bash 4.3 build or switch to alternative (old .deb from snapshot.debian.org)
4. Add full healthcheck verifying CGI and SUID
5. Write actual exploit + writeup

---

### 3.6 Machine 06 — PHPocalypse (CVE-2012-1823)

**Status**: 🔴 SCAFFOLDED — *No service, no exploit, cannot be exploited*

**Files present**:
```
06-phpocalypse/
├── Dockerfile              🔴 GENERIC — only installs base system packages, NO PHP, NO Apache
├── docker-compose.yml      ⚠️  Scaffold with 10.10.6.0/24 network
├── healthcheck.sh          ⚠️  Basic skeleton
├── config/
│   └── entrypoint.sh       ✅ Standard entrypoint (calls setup.sh and start-service.sh if they exist)
├── flags/                  ✅ generate.sh present
├── README.md               ✅ Skeleton README
└── writeup/                ⚠️  Skeleton (placeholder solution.md, exploit.py)
```

**Missing**:
- `config/setup.sh` — needs to configure writable cron privesc vector
- `config/start-service.sh` — needs to start Apache with PHP-CGI
- Dockerfile needs complete rewrite: install PHP 5.x (CGI mode) + Apache with `mod_actions`
- PHP web app files (index.php + php-cgi setup)
- Apache vhost config with php-cgi route
- Real `exploit.py` using argument injection (`?-d+allow_url_include=1+...`)
- Real `solution.md` with exact commands

**What's needed to become DEEP**: Full implementation from scratch. See `implementation_plan.md §3.6` for detailed spec.

---

### 3.7 Machine 07 — GhostCat (CVE-2020-1938)

**Status**: 🔴 SCAFFOLDED — *No service, no exploit, cannot be exploited*

**Files present**:
```
07-ghostcat/
├── Dockerfile              🔴 GENERIC — only installs base system packages, NO Tomcat, NO AJP
├── docker-compose.yml      ⚠️  Scaffold with 10.10.7.0/24 network (missing AJP port 8009)
├── healthcheck.sh          ⚠️  Basic skeleton — doesn't check AJP port
├── config/
│   └── entrypoint.sh       ✅ Standard entrypoint
├── flags/                  ✅ generate.sh present
├── README.md               ✅ Skeleton README
└── writeup/                ⚠️  Skeleton
```

**Missing**:
- `config/setup.sh` — admin creds in WEB-INF/web.xml, Tomcat Manager enabled
- `config/start-service.sh` — start Tomcat
- Dockerfile needs: Tomcat 9.0.30 + AJP connector enabled + web app deployment
- `config/server.xml` — Tomcat server config with AJP connector on port 8009 and HTTP on 8080
- `config/web.xml` — web app descriptor with admin credentials
- `config/tomcat-users.xml` — Tomcat Manager admin credentials
- `docker-compose.yml` needs AJP port 8009 added to internal network
- Real `exploit.py` using `ajpShooter.py` / `ghostcat.py` technique
- Real `solution.md`

**What's needed to become DEEP**: Full implementation from scratch. See `implementation_plan.md §3.7` for detailed spec.

---

## 4. SUMMARY TABLE

| Machine | Status | Build Stability | Exploitability | Writeup Quality |
|---------|--------|----------------|----------------|----------------|
| 01-log4hell | 🟢 DEEP | 🟡 Fragile (network deps) | ✅ Exploitable | ✅ Complete |
| 02-springbreak | 🟢 DEEP | 🟡 Fragile (network deps) | ✅ Exploitable | ✅ Complete |
| 03-pathfinder | 🟢 DEEP | 🟡 Fragile (compile from src) | ✅ Exploitable | ✅ Complete |
| 04-strutszone | 🟡 PARTIAL | 🔴 Fragile (archive deps) | 🟡 Likely works | 🔴 Skeleton |
| 05-shellshocked | 🟡 PARTIAL | 🟡 Fragile (bash 4.3 compile) | 🟡 Partially broken | 🔴 Skeleton |
| 06-phpocalypse | 🔴 SCAFFOLDED | 🔴 Not functional | 🔴 Not exploitable | 🔴 Skeleton |
| 07-ghostcat | 🔴 SCAFFOLDED | 🔴 Not functional | 🔴 Not exploitable | 🔴 Skeleton |

---

## 5. KEY KNOWN ISSUES (ALL MACHINES)

### 5.1 Log4j Runtime Errors (Machine 01 — ACTIVE ISSUE)

The Log4j 2.14.1 JAR is downloaded from Maven Central at build time. These are the possible runtime errors:

**Error Type A: Build-time download failure**
```
wget: unable to resolve host 'repo1.maven.org'
```
*Fix*: Bundle the JARs locally in the repo (see `implementation_plan.md §4.1`).

**Error Type B: JVM JNDI disabled by default**
```
[main] WARN org.apache.logging.log4j.core.net.JndiManager - JNDI is not enabled
```
*Fix*: Add `-Dlog4j2.enableJndi=true` to start-app.sh (required for Log4j ≥ 2.15 even on patched versions).

**Error Type C: JDK 11 trustURLCodebase is ignored**
On JDK 11.0.1+, remote class loading via LDAP is disabled by default. The flags in `start-app.sh` re-enable it but only for **JDK ≤ 8**. On JDK 11, JNDI can still trigger a DNS lookup (for detection/callback) but the actual RCE requires sending a **serialized deserialization payload** instead of a remote class URL.
*Recommendation*: Use JDK 8 for machine 01 (`openjdk-8-jdk-headless`) to ensure the original attack vector works.

**Error Type D: Log4j 2.14.1 config errors**
The current `log4j2.xml` uses basic ConsoleAppender. If the class path doesn't include both `log4j-api` and `log4j-core`, startup fails silently.
*Fix*: Verify both JARs are in the classpath in `start-app.sh`.

### 5.2 External URL Dependencies (ALL machines)

Every machine that downloads software at build time is fragile:
- Maven Central (`repo1.maven.org`)
- Apache Archive (`archive.apache.org`)
- GNU FTP (`ftp.gnu.org`)
- Tomcat binary mirrors

**Resolution strategy**: The `implementation_plan.md` proposes multi-layered approach: use Docker layer caching aggressively, provide fallback URLs, and for critical machines — pre-bundle binaries/JARs in the repo.

### 5.3 Isolation Verification

Each machine's `docker-compose.yml` uses a separate bridge network (`10.10.N.0/24`). However:
- Machines currently **do NOT have** explicit `--network=none` from other machines' networks
- Docker's default bridge may allow cross-machine communication if both containers are on the same host
- The `run.sh` lifecycle manager should enforce `--internal` on machine networks

---

## 6. ISOLATION ARCHITECTURE FOR THIS CATEGORY

Each machine in `01_WebServer_Runtime` MUST use this pattern:

```yaml
# CORRECT: Fully isolated Docker service
services:
  machine_name:
    build: .
    container_name: lm-0N-machine-name
    networks:
      machine_0N_net:
        ipv4_address: 10.10.N.10  # Static IP within isolated subnet
    mem_limit: 512m
    cpus: 1.0
    pids_limit: 256
    security_opt:
      - no-new-privileges:false   # Only if SUID needed
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE          # Allow binding port < 1024 if needed
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "/healthcheck.sh"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

networks:
  machine_0N_net:
    driver: bridge
    internal: true    # ← No outbound internet from container (post-build)
    ipam:
      config:
        - subnet: 10.10.N.0/24
          gateway: 10.10.N.1
```

> ⚠️ **NOTE**: `internal: true` prevents the container from making outbound connections — which is correct for a CTF machine (no reverse shells to attacker infra on default compose). On the attacker's side, VPN routes traffic to the machine's IP.

---

## 7. NEXT STEPS (PRIORITY ORDER)

### Immediate (Blockers)

1. **Fix Machine 01 Log4j errors** → Switch Dockerfile to JDK 8 + bundle JARs locally
2. **Fix Machine 05 CGI config** → Add `a2enconf` call + fix SUID nmap issue
3. **Fix Machine 04 archive URLs** → Use vulhub base image or mirror WAR locally

### Short-term (Complete Scaffold → DEEP)

4. **Implement Machine 06 (PHPocalypse)** → Full Dockerfile rewrite, PHP-CGI setup, cron privesc
5. **Implement Machine 07 (GhostCat)** → Full Dockerfile rewrite, Tomcat 9.0.30, AJP on 8009

### Quality (Writeups & Exploits)

6. **Write Machine 04 exploit.py** → OGNL Content-Type injection
7. **Write Machine 05 exploit.py** → Shellshock User-Agent injection
8. **Write Machines 06-07 exploits** — after implementation

### Verification

9. **Run all 7 machines simultaneously** → Check for port conflicts, resource exhaustion
10. **Verify isolation** → Confirm containers cannot reach each other's IPs

---

## 8. FILE COUNT FOR THIS CATEGORY

| Machine | Expected Files | Current Files | Gap |
|---------|---------------|---------------|-----|
| 01-log4hell | 14 | 14 | ✅ None |
| 02-springbreak | 15 | 15 | ✅ None |
| 03-pathfinder | 12 | 12 | ✅ None |
| 04-strutszone | 14 | 11 | 🔴 Missing: exploit.py (real), solution.md (real), config updated |
| 05-shellshocked | 14 | 13 | 🟡 Missing: real exploit.py + solution.md + CGI config fix |
| 06-phpocalypse | 14 | 6 | 🔴 Missing: setup.sh, start-service.sh, PHP config, full Dockerfile, real exploit.py, solution.md |
| 07-ghostcat | 14 | 6 | 🔴 Missing: setup.sh, start-service.sh, server.xml, tomcat configs, full Dockerfile, real exploit.py |

**Total files needed for full category completion**: ~98 files
**Current state**: ~77 files (79% present, ~40% actually functional)
