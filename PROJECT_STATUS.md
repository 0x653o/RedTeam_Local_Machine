# 🏴 LOCAL-MACHINE — COMPLETE PROJECT STATUS & CONTEXT

> **Last Updated**: 2026-04-01
> **Purpose**: Full context document so work can resume from any new conversation.
> **Key Reference**: `implementation_plan.md` (723 lines) is the master blueprint.

---

## 1. PROJECT OVERVIEW

A 42-machine, Docker-based penetration testing lab. Each machine is an isolated container running a real CVE vulnerability. Players exploit them following a strict kill chain: RECON → ENUMERATE → EXPLOIT → POST-EXPLOIT. Inspired by HackTheBox/DEFCON CTF Finals.

**Core Design Principles**:
- "Cogwheel" model: each step is a hard gate for the next
- Real CVEs only (CVSS ≥ 7.0)
- Isolated Docker networks per machine (10.10.{N}.0/24)
- Deterministic flags from SHA256(FLAG_SEED + machine_id)
- Auto-recovery via lifecycle manager (60-min resets)
- Escape challenges gated behind `--enable-escape-challenges` flag

---

## 2. WHAT IS FULLY COMPLETE (WORKING)

### 2.1 Infrastructure (all done)
| File | Status | Description |
|------|--------|-------------|
| `.env` | ✅ Done | FLAG_SEED, SUBNET_BASE, VPN_PORT, PORTAL_SECRET, ENABLE_ESCAPE |
| `run.sh` | ✅ Done | Admin CLI: up/down/reset/status/logs/health/vpn-add/vpn-list |
| `lifecycle-manager.sh` | ✅ Done | Auto-recovery daemon, 60-min resets, health monitoring |
| `docker-compose.yml` | ✅ Done | Root compose for VPN + Portal |
| `.gitignore` | ✅ Done | Secrets, data, certs, node_modules |
| `README.md` | ✅ Done | Project overview + quick start |
| `LICENSE` | ✅ Done | MIT + educational disclaimer |
| `CONTRIBUTING.md` | ✅ Done | Machine creation checklist |

### 2.2 Shared Utilities (all done)
| File | Status |
|------|--------|
| `infra/shared/flag-generator.sh` | ✅ Deterministic flag generation |
| `infra/shared/healthcheck-base.sh` | ✅ Reusable health check functions |

### 2.3 VPN Gateway (done)
| File | Status |
|------|--------|
| `infra/vpn/docker-compose.yml` | ✅ WireGuard with auto peer generation |

### 2.4 Web Portal — Gamified Dashboard (all done)
| File | Status |
|------|--------|
| `infra/portal/docker-compose.yml` | ✅ Portal compose |
| `infra/portal/Dockerfile` | ✅ Node.js Alpine + self-signed TLS |
| `infra/portal/package.json` | ✅ Express + cookie-parser |
| `infra/portal/src/server.js` | ✅ **356 lines** — Full API: login, flag validation, profiles, first blood, heatmap, machine list. All 42 machines defined in MACHINES array. |
| `infra/portal/src/templates/index.html` | ✅ Dashboard with 4 sections: Command Center, Machine Browser, Heatmap, Profile |
| `infra/portal/src/templates/login.html` | ✅ Login page with shared-secret auth |
| `infra/portal/src/static/css/dashboard.css` | ✅ Dark theme, glassmorphism, micro-animations |
| `infra/portal/src/static/js/dashboard.js` | ✅ Async data loading, filtering, animated stats, toasts |

### 2.5 Scripts (all done)
| File | Status |
|------|--------|
| `scripts/generate-all-flags.sh` | ✅ Batch flag gen for 42 machines |
| `scripts/reset-machine.sh` | ✅ Single machine reset |
| `scripts/reset-all.sh` | ✅ Reset all |
| `scripts/validate-machines.sh` | ✅ Health check validation w/ color output |
| `scripts/generate-machines.py` | ✅ Python generator that created machines 04-42 |

### 2.6 Documentation (all done)
| File | Status |
|------|--------|
| `docs/01_SETUP.md` | ✅ Prerequisites, installation, troubleshooting |
| `docs/02_ARCHITECTURE.md` | ✅ Network topology, isolation model, security boundaries |
| `docs/03_ADMIN_GUIDE.md` | ✅ Operations, lifecycle config, resource management |
| `docs/04_PLAYER_GUIDE.md` | ✅ VPN setup, methodology, points/ranks, machine IPs |
| `docs/05_ANONYMOUS_USER.md` | ✅ Beginner guide with glossary |
| `docs/MITRE_ATTACK_MAP.md` | ✅ Full ATT&CK coverage matrix |
| `docs/school_server_deploy/Option1_VPN_Allowed.md` | ✅ Open port deployment |
| `docs/school_server_deploy/Option2_Outbound_Only.md` | ✅ Tailscale/CF Tunnel |

### 2.7 Extra Files (done)
| File | Status |
|------|--------|
| `machines/02_CMS_WebApp/09-pressgrave/docker-compose.escape.yml` | ✅ Docker socket escape override |
| `machines/03_Framework_Library/21-weblogicbmb/docker-compose.escape.yml` | ✅ Privileged escape override |
| `machines/07_Privilege_Escalation/38-dirtypipe/docker-compose.escape.yml` | ✅ cgroup escape override |
| `machines/08_Advanced_Exploitation/39-v8-maprem/docker-compose.arm64.yml` | ✅ ARM64 override |
| `machines/08_Advanced_Exploitation/39-v8-maprem/Dockerfile.arm64` | ✅ ARM64 Dockerfile |
| `machines/04_Enterprise_Middleware/25-redisraider/docker-compose.mips.yml` | ✅ MIPS override |
| `machines/08_Advanced_Exploitation/39-v8-maprem/v8-build/BUILD_FROM_SOURCE.md` | ✅ V8 build docs |
| `machines/08_Advanced_Exploitation/40-v8-turboconf/v8-build/BUILD_FROM_SOURCE.md` | ✅ V8 build docs |
| `machines/08_Advanced_Exploitation/41-v8-oobarray/v8-build/BUILD_FROM_SOURCE.md` | ✅ V8 build docs |
| `machines/08_Advanced_Exploitation/42-jsc-jitrce/jsc-build/BUILD_FROM_SOURCE.md` | ✅ JSC + PAC docs |
| `machines/08_Advanced_Exploitation/39-v8-maprem/harness/d8-harness.sh` | ✅ d8 REPL via socat |
| `machines/08_Advanced_Exploitation/39-v8-maprem/harness/poc.js` | ✅ CheckMaps PoC |
| `machines/08_Advanced_Exploitation/40-v8-turboconf/harness/poc.js` | ✅ TurboFan PoC |
| `machines/08_Advanced_Exploitation/41-v8-oobarray/harness/poc.js` | ✅ OOB PoC |
| `machines/08_Advanced_Exploitation/42-jsc-jitrce/harness/poc.js` | ✅ DFG PoC |

---

## 3. MACHINE IMPLEMENTATION STATUS — THE CRITICAL PART

### 3.1 Status Legend

- **🟢 DEEP**: Fully implemented. Has custom vulnerable app code, specific Dockerfile installing exact vulnerable version, working exploit, custom privesc setup. Would actually build and run.
- **🟡 SCAFFOLDED**: Has all 9 standard files (docker-compose.yml, Dockerfile, healthcheck.sh, config/entrypoint.sh, flags/generate.sh, README.md, writeup/solution.md, writeup/exploit.py, writeup/references.md). But the Dockerfile uses a GENERIC template and the entrypoint calls `config/setup.sh` and `config/start-service.sh` WHICH DO NOT EXIST. Container would start but just run `tail -f /dev/null`.

### 3.2 Per-Machine Status

| # | Name | CVE | Status | Config Files | What's Missing |
|---|------|-----|--------|-------------|----------------|
| 01 | Log4Hell | CVE-2021-44228 | 🟢 DEEP | 5 (VulnApp.java, vuln-reader.c, log4j2.xml, start-app.sh, entrypoint.sh) | Nothing — fully working |
| 02 | SpringBreak | CVE-2022-22965 | 🟢 DEEP | 3 (entrypoint.sh, setup-cron.sh, vuln-app/README.md) | Needs actual Spring WAR file download in Dockerfile |
| 03 | PathFinder | CVE-2021-41773 | 🟢 DEEP | 1 (entrypoint.sh) | Apache 2.4.49 source build is in Dockerfile. Needs httpd.conf |
| 04 | StrutsZone | CVE-2017-5638 | 🟡 SCAFFOLDED | 1 (entrypoint.sh) | Needs setup.sh + start-service.sh |
| 05 | ShellShocked | CVE-2014-6271 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 06 | PHPocalypse | CVE-2012-1823 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 07 | GhostCat | CVE-2020-1938 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 08 | DrupalDoom | CVE-2018-7600 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 09 | PressGrave | CVE-2022-0739 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 10 | BulletProof | CVE-2019-16759 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 11 | Confluencer | CVE-2022-26134 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 12 | GitLabyrinth | CVE-2021-22205 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 13 | GrafanLeak | CVE-2021-43798 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 14 | JoomBleed | CVE-2023-23752 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 15 | Ignition | CVE-2021-3129 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 16 | ThinkPwned | CVE-2018-20062 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 17 | ImageTragick | CVE-2016-3714 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 18 | ProtoPoison | CWE-1321 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 19 | PickleRick | CWE-502 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 20 | JWTwisted | CVE-2022-21449 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 21 | WebLogicBmb | CVE-2019-2725 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 22 | React2Shell | CVE-2025-55182 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 23 | JenkinsOwned | CVE-2024-23897 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 24 | ActiveMQtter | CVE-2023-46604 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 25 | RedisRaider | Miscfg | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 26 | MongoMayhem | Miscfg+NoSQLi | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 27 | ElasticPwn | CVE-2015-1427 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 28 | SolrBlaze | CVE-2019-17558 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 29 | BigIPwned | CVE-2022-1388 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 30 | CitrixBreaker | CVE-2019-19781 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 31 | IvantiGate | CVE-2024-21887 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 32 | MinIOLeaker | CVE-2023-28432 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 33 | MOVEitMstr | CVE-2023-34362 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 34 | ApacheNght | CVE-2023-25690 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 35 | GoAnywher | CVE-2023-0669 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 36 | BaronSamedit | CVE-2021-3156 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 37 | PwnKit | CVE-2021-4034 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 38 | DirtyPipe | CVE-2022-0847 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 39 | V8_MapRem | CVE-2018-17463 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 40 | V8_TurboConf | CVE-2020-6418 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 41 | V8_OOBArray | CVE-2021-30632 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |
| 42 | JSC_JITRCE | CVE-2020-9802 | 🟡 SCAFFOLDED | 1 | Needs setup.sh + start-service.sh |

---

## 4. WHAT EACH SCAFFOLDED MACHINE NEEDS TO BECOME FULLY WORKING

Every 🟡 SCAFFOLDED machine (04-42) needs **three things** to become functional:

### 4.1 File: `config/setup.sh`
Runs once at container startup (called by entrypoint.sh). Sets up:
- The privilege escalation vector (SUID binary, writable cron, sudo miscfg, SSH keys, etc.)
- Any additional service configuration
- Application-specific files

### 4.2 File: `config/start-service.sh`
Starts the actual vulnerable service (called by entrypoint.sh via `exec`). This is the foreground process that keeps the container alive.

### 4.3 Updated `Dockerfile`
The current Dockerfile for scaffolded machines is GENERIC — it just installs base packages. Each machine needs its Dockerfile updated to:
- Install the specific vulnerable software version
- Download/compile the vulnerable application
- Set up the service configuration
- Possibly compile privesc binaries

### 4.4 Additionally needed per machine:
- **Updated `writeup/exploit.py`**: Currently a skeleton with TODO. Needs actual CVE-specific exploit code.
- **Updated `writeup/solution.md`**: Currently a template. Needs detailed step-by-step with exact commands.

---

## 5. DETAILED PER-MACHINE REQUIREMENTS (WHAT TO BUILD)

### Machine 04: StrutsZone (CVE-2017-5638)
**Dockerfile needs**: Apache Struts 2.3.x WAR deployed on Tomcat 8.x
**setup.sh needs**: Configure sudo misconfiguration (e.g., `tomcat ALL=(ALL) NOPASSWD: /usr/bin/find`)
**start-service.sh needs**: Start Tomcat with the vulnerable Struts WAR
**Exploit**: OGNL injection in Content-Type header → `Content-Type: %{(#cmd='id')...}`
**Key files to create**: Struts2 showcase WAR or minimal vulnerable app

### Machine 05: ShellShocked (CVE-2014-6271)
**Dockerfile needs**: Apache 2.x with mod_cgi, old bash (4.3 or lower)
**setup.sh needs**: Install SUID nmap binary (`chmod u+s /usr/bin/nmap`), create CGI scripts in /usr/lib/cgi-bin/
**start-service.sh needs**: Start Apache httpd
**Exploit**: `User-Agent: () { :; }; /bin/bash -c 'reverse_shell'`
**Key files to create**: Simple CGI bash scripts (test.cgi, status.cgi)

### Machine 06: PHPocalypse (CVE-2012-1823)
**Dockerfile needs**: PHP 5.3.x or 5.4.x compiled with `--enable-cgi`, Apache with mod_actions pointing to php-cgi
**setup.sh needs**: Writable cron script in /opt/scripts/ run by root cron
**start-service.sh needs**: Start Apache
**Exploit**: `?-d+allow_url_include=1+-d+auto_prepend_file=php://input` with POST body PHP code
**Key files to create**: PHP web app files, php-cgi config, Apache vhost config

### Machine 07: GhostCat (CVE-2020-1938)
**Dockerfile needs**: Tomcat 9.0.30 with AJP connector enabled on port 8009
**setup.sh needs**: Place admin credentials in WEB-INF/web.xml, enable Tomcat Manager
**start-service.sh needs**: Start Tomcat (catalina.sh run)
**Exploit**: Use `ajpShooter.py` or `ghostcat.py` to read WEB-INF/web.xml via AJP
**Key files to create**: Tomcat server.xml (AJP enabled), web.xml with creds, sample webapp

### Machine 08: DrupalDoom (CVE-2018-7600)
**Dockerfile needs**: Drupal 7.57 or 8.5.0 on Apache+PHP+MySQL (or MariaDB)
**setup.sh needs**: MySQL creds in settings.php, sudo miscfg for www-data
**start-service.sh needs**: Start Apache + MySQL
**Exploit**: Drupalgeddon2 Form API render array RCE
**Key files to create**: Drupal installation, MySQL init script, settings.php

### Machine 09: PressGrave (CVE-2022-0739)
**Dockerfile needs**: WordPress 5.x + vulnerable plugin (e.g., BookingPress < 1.0.11), MySQL
**setup.sh needs**: WP install, plugin activation, Docker socket mount (via escape compose)
**start-service.sh needs**: Start Apache + MySQL
**Exploit**: SQLi in plugin → dump hashes → crack → theme editor RCE
**Key files to create**: WP config, plugin files, MySQL init, Docker escape instructions

### Machine 10: BulletProof (CVE-2019-16759)
**Dockerfile needs**: vBulletin 5.x (pre-auth RCE via widgetConfig)
**setup.sh needs**: Hidden cronjob running as root with writable script
**start-service.sh needs**: Start Apache + MySQL + vBulletin
**Exploit**: POST to `ajax/render/widget_tabbedcontainer_tab_panel` with widgetConfig[code]
**Key files to create**: vBulletin files, MySQL schema, cronjob setup

### Machine 11: Confluencer (CVE-2022-26134)
**Dockerfile needs**: Atlassian Confluence 7.13.6 or similar (pre-patch)
**setup.sh needs**: SSH key pair — place private key in confluence home, same key in root's authorized_keys
**start-service.sh needs**: Start Confluence (standalone or via Tomcat)
**Exploit**: OGNL injection in URL: `/${...OGNL_PAYLOAD...}/`
**Key files to create**: Confluence standalone setup, SSH key pair

### Machine 12: GitLabyrinth (CVE-2021-22205)
**Dockerfile needs**: GitLab CE 13.10.2 or similar (huge image — consider using official GitLab Docker)
**setup.sh needs**: Create admin repo containing root SSH key
**start-service.sh needs**: Start GitLab (gitlab-ctl reconfigure + start)
**Exploit**: Upload DjVu file with ExifTool command injection metadata
**Key files to create**: DjVu malicious file template, Rails console commands doc
**NOTE**: GitLab is a very large container (2GB+). May need special handling.

### Machine 13: GrafanLeak (CVE-2021-43798)
**Dockerfile needs**: Grafana 8.2.x (before 8.3.0 patch)
**setup.sh needs**: SQLite DB with stored creds, SSH creds that work for root
**start-service.sh needs**: Start Grafana server
**Exploit**: Path traversal: `/public/plugins/alertlist/../../../../etc/grafana/grafana.db`
**Key files to create**: Grafana config (grafana.ini), pre-seeded SQLite database

### Machine 14: JoomBleed (CVE-2023-23752)
**Dockerfile needs**: Joomla 4.2.7 on Apache+PHP+MySQL
**setup.sh needs**: Sudo miscfg (e.g., www-data can run /usr/bin/vi as root)
**start-service.sh needs**: Start Apache + MySQL
**Exploit**: `/api/index.php/v1/config/application?public=true` leaks DB creds
**Key files to create**: Joomla config, MySQL init, template with PHP exec

### Machine 15: Ignition (CVE-2021-3129)
**Dockerfile needs**: Laravel 8.x with Ignition 2.5.1
**setup.sh needs**: Place root SSH key in /opt/backup/.ssh/
**start-service.sh needs**: Start PHP artisan serve (dev mode with debug ON)
**Exploit**: POST to `/_ignition/execute-solution` → phar file write → RCE
**Key files to create**: Laravel project skeleton, .env with APP_DEBUG=true

### Machine 16: ThinkPwned (CVE-2018-20062)
**Dockerfile needs**: ThinkPHP 5.0.x on Apache/Nginx+PHP
**setup.sh needs**: SUID `find` binary (`chmod u+s /usr/bin/find`)
**start-service.sh needs**: Start web server
**Exploit**: `/index.php?s=index/\think\app/invokefunction&function=call_user_func_array&vars[0]=system&vars[1][]=id`
**Key files to create**: ThinkPHP project files

### Machine 17: ImageTragick (CVE-2016-3714)
**Dockerfile needs**: ImageMagick 6.9.x (before patch), PHP upload form
**setup.sh needs**: Cron job running `convert` on uploaded images as root
**start-service.sh needs**: Start Apache
**Exploit**: Upload MVG file: `push graphic-context\nviewbox 0 0 640 480\nimage over 0,0 0,0 'https://example.com"|id"'\npop graphic-context`
**Key files to create**: PHP upload form, ImageMagick policy.xml (permissive), cron script

### Machine 18: ProtoPoison (CWE-1321)
**Dockerfile needs**: Node.js 18 + Express + EJS templates (FROM node:18-slim already set)
**setup.sh needs**: Nothing special — container already runs as root
**start-service.sh needs**: `node /opt/config/app.js`
**Exploit**: POST JSON with `{"__proto__":{"outputFunctionName":"x;process.mainModule.require('child_process').exec('...')}}`
**Key files to create**: Express app.js with deep merge function + EJS templates

### Machine 19: PickleRick (CWE-502)
**Dockerfile needs**: Python 3.11 + Flask (FROM python:3.11-slim already set) + Redis
**setup.sh needs**: Redis instance with SSH key stored, SSH key that works for root
**start-service.sh needs**: Start Redis + Flask app
**Exploit**: Base64 decode session cookie → craft pickle payload → replace cookie → RCE
**Key files to create**: Flask app with pickle session, Redis config, requirements.txt

### Machine 20: JWTwisted (CVE-2022-21449)
**Dockerfile needs**: Java 17 (early build with ECDSA bug) + Spring Boot API
**setup.sh needs**: Internal service on different port accessible via SSRF
**start-service.sh needs**: Start Java API
**Exploit**: Forge JWT with empty ECDSA signature (r=0, s=0 bypass)
**Key files to create**: Spring Boot API JAR, JWT validation code, internal service

### Machine 21: WebLogicBmb (CVE-2019-2725)
**Dockerfile needs**: Oracle WebLogic 10.3.6 or 12.1.3
**setup.sh needs**: Nothing — container runs as root
**start-service.sh needs**: Start WebLogic
**Exploit**: POST XMLDecoder payload to `/_async/AsyncResponseService`
**Key files to create**: WebLogic domain config, AsyncResponseService endpoint
**NOTE**: WebLogic requires Oracle JDK and is large. Consider using vulhub images.

### Machine 22: React2Shell (CVE-2025-55182)
**Dockerfile needs**: Next.js 15.x with React 19.x (FROM node:20 already set)
**setup.sh needs**: PostgreSQL with SSH keys in secrets table, sudo miscfg
**start-service.sh needs**: Start Next.js + PostgreSQL
**Exploit**: Craft malicious RSC Flight protocol payload → deserialization RCE
**Key files to create**: Next.js App Router project, PostgreSQL init script, React Server Components
**NOTE**: This is a CVSS 10.0 — most complex machine. Needs detailed RSC Flight format documentation.

### Machine 23: JenkinsOwned (CVE-2024-23897)
**Dockerfile needs**: Jenkins 2.441 (before patch) with plugins
**setup.sh needs**: Store SSH credentials in Jenkins credential store, create master.key
**start-service.sh needs**: Start Jenkins
**Exploit**: `java -jar jenkins-cli.jar -s http://target:8080 who-am-i @/etc/passwd` (CLI file read)
**Key files to create**: Jenkins home with encrypted credentials, hudson.util.Secret

### Machine 24: ActiveMQtter (CVE-2023-46604)
**Dockerfile needs**: Apache ActiveMQ 5.15.x or 5.16.x (before 5.15.16/5.16.7)
**setup.sh needs**: Service account sudo (activemq user can sudo certain commands)
**start-service.sh needs**: Start ActiveMQ
**Exploit**: ClassInfo ExceptionResponse deserialization via OpenWire protocol
**Key files to create**: ActiveMQ config, ClassPathXmlApplicationContext payload XML

### Machine 25: RedisRaider (Misconfiguration)
**Dockerfile needs**: Redis 6.x or 7.x with NO password (bind 0.0.0.0)
**setup.sh needs**: Root SSH enabled, authorized_keys directory exists
**start-service.sh needs**: Start Redis + SSH
**Exploit**: `redis-cli -h target CONFIG SET dir /root/.ssh` → SET key pubkey → SAVE
**Key files to create**: Redis config (no requirepass, no protected-mode)

### Machine 26: MongoMayhem (Miscfg + NoSQLi)
**Dockerfile needs**: MongoDB 4.x (no auth) + Node.js webapp
**setup.sh needs**: Pre-seed users collection with admin creds
**start-service.sh needs**: Start MongoDB + Node.js webapp
**Exploit**: Connect to Mongo → dump creds → login to webapp → NoSQLi: `{"username":{"$gt":""},"password":{"$gt":""}}`
**Key files to create**: Node.js webapp with NoSQLi-vulnerable login, MongoDB seed script

### Machine 27: ElasticPwn (CVE-2015-1427)
**Dockerfile needs**: Elasticsearch 1.4.x (Groovy scripting enabled)
**setup.sh needs**: Config files with root password (credential reuse)
**start-service.sh needs**: Start Elasticsearch
**Exploit**: `POST /_search` with Groovy script: `{"script_fields":{"exploit":{"script":"java.lang.Runtime.getRuntime().exec('id')"}}}`
**Key files to create**: Elasticsearch config, seed data

### Machine 28: SolrBlaze (CVE-2019-17558)
**Dockerfile needs**: Apache Solr 8.1.x or 8.2.x (Velocity template enabled)
**setup.sh needs**: SSH creds logged in solr.log files
**start-service.sh needs**: Start Solr
**Exploit**: Enable Velocity via Config API → inject Velocity template → RCE
**Key files to create**: Solr config, core with data, startup script

### Machine 29: BigIPwned (CVE-2022-1388)
**Dockerfile needs**: Simulated F5 BIG-IP management API (Flask/Node mock)
**setup.sh needs**: Nothing — appliance runs as root
**start-service.sh needs**: Start mock management API on 443
**Exploit**: Header manipulation: `Connection: X-F5-Auth-Token` + `X-F5-Auth-Token:` (empty) bypasses auth
**Key files to create**: Mock iControl REST API with auth bypass vulnerability
**NOTE**: Cannot run actual BIG-IP. Build a faithful API mock.

### Machine 30: CitrixBreaker (CVE-2019-19781)
**Dockerfile needs**: Simulated Citrix ADC/NetScaler (Python/Perl webapp)
**setup.sh needs**: Perl template directory writable
**start-service.sh needs**: Start web server
**Exploit**: Path traversal → write Perl template → trigger template execution
**Key files to create**: Mock Citrix ADC with /vpn/ path, Perl template engine

### Machine 31: IvantiGate (CVE-2024-21887)
**Dockerfile needs**: Simulated Ivanti Connect Secure API (Python mock)
**setup.sh needs**: Nothing — appliance runs as root
**start-service.sh needs**: Start mock Ivanti API
**Exploit**: Auth bypass chain + command injection in API endpoint
**Key files to create**: Mock Ivanti API with auth bypass and cmd injection

### Machine 32: MinIOLeaker (CVE-2023-28432)
**Dockerfile needs**: MinIO server (MINIO_ROOT_USER/PASSWORD set)
**setup.sh needs**: Create bucket with SSH private key, SSH root enabled
**start-service.sh needs**: Start MinIO server
**Exploit**: `GET /minio/health/cluster` leaks environment variables including S3 keys
**Key files to create**: MinIO startup, bucket creation script, SSH key placement

### Machine 33: MOVEitMstr (CVE-2023-34362)
**Dockerfile needs**: Simulated MOVEit Transfer (ASP.NET mock or Python)
**setup.sh needs**: Nothing — service runs as system/root
**start-service.sh needs**: Start mock MOVEit
**Exploit**: SQLi in session handling → session token extraction → impersonate admin → deserialization RCE
**Key files to create**: Mock MOVEit with vulnerable session handling, SQLi endpoint
**NOTE**: Real MOVEit is Windows/.NET. Build a faithful mock.

### Machine 34: ApacheNght (CVE-2023-25690)
**Dockerfile needs**: Apache 2.4.55 (before fix) with mod_proxy + mod_rewrite
**setup.sh needs**: Backend service with management API behind auth
**start-service.sh needs**: Start Apache reverse proxy + backend
**Exploit**: HTTP request smuggling via `\r\n` in RewriteRule → bypass auth → access management API
**Key files to create**: Apache config with RewriteRule, backend Flask API

### Machine 35: GoAnywher (CVE-2023-0669)
**Dockerfile needs**: Simulated GoAnywhere MFT (Java mock)
**setup.sh needs**: Nothing — service runs as root
**start-service.sh needs**: Start mock GoAnywhere
**Exploit**: License portal endpoint → AES-encrypted serialized object → deserialization RCE
**Key files to create**: Java webapp mocking GoAnywhere License endpoint with deserialization
**NOTE**: Real GoAnywhere is commercial. Build a mock.

### Machine 36: BaronSamedit (CVE-2021-3156)
**Dockerfile needs**: Ubuntu 20.04 with sudo 1.8.31 (vulnerable version)
**setup.sh needs**: PHP web upload form for initial foothold, install specific sudo version
**start-service.sh needs**: Start Apache with PHP
**Exploit**: `sudoedit -s '\' $(python3 -c 'print("A"*0x500)')` → heap overflow → root shell
**Key files to create**: PHP upload form, sudoedit exploit binary (or compile from source)
**NOTE**: Requires specific sudo 1.8.31 package. May need to pin apt version.

### Machine 37: PwnKit (CVE-2021-4034)
**Dockerfile needs**: Ubuntu 20.04 with vulnerable polkit/pkexec
**setup.sh needs**: Python Flask app with Jinja2 SSTI vulnerability
**start-service.sh needs**: Start Flask app
**Exploit**: SSTI via `{{config.__class__.__init__.__globals__['os'].popen('id').read()}}` → pkexec exploit
**Key files to create**: Flask app with SSTI, pkexec exploit (C source or pre-compiled)

### Machine 38: DirtyPipe (CVE-2022-0847)
**Dockerfile needs**: Ubuntu with kernel 5.8+ (tricky in Docker — may need custom kernel module approach)
**setup.sh needs**: SSRF endpoint + internal webapp with SSTI
**start-service.sh needs**: Start both webapps
**Exploit**: SSRF → reach internal app → SSTI → shell → DirtyPipe overwrite /etc/passwd
**Key files to create**: SSRF webapp, internal SSTI webapp, DirtyPipe exploit C source
**NOTE**: Kernel exploits in containers are tricky. DirtyPipe uses splice() which works inside containers IF the host kernel is vulnerable. Document this limitation.

### Machines 39-42: V8/JSC Browser Exploitation
**All need**: Vulnerable d8/jsc binary (pre-built or compiled from source)
**setup.sh needs**: Download pre-built binary, install socat for REPL harness
**start-service.sh needs**: Run d8-harness.sh (socat TCP→d8)
**Exploit**: JavaScript exploit targeting specific JIT bugs
**Key files to create**: Full exploit.js (not just PoC), shellcode payloads, d8-harness.sh per machine
**NOTE**: Pre-built d8 binaries need to be hosted somewhere (GitHub Releases). The BUILD_FROM_SOURCE.md docs are already written.

---

## 6. GENERIC ENTRYPOINT PATTERN (used by machines 04-42)

The scaffolded machines' `config/entrypoint.sh` does this:
```bash
1. Generate flags (root.txt + user.txt)
2. Start SSH daemon
3. If config/setup.sh exists → run it (sets up privesc, configs)
4. If config/start-service.sh exists → exec it (starts vulnerable service)
5. Otherwise → tail -f /dev/null (container stays alive but does nothing)
```

**To make a machine work**: Create `config/setup.sh` and `config/start-service.sh`.

---

## 7. REFERENCE: HOW MACHINE 01 (LOG4HELL) WAS BUILT

This is the gold standard. Every machine should follow this pattern:

```
01-log4hell/
├── docker-compose.yml      # Isolated network 10.10.1.0/24, resource limits
├── Dockerfile              # Downloads Log4j 2.14.1 JARs, compiles VulnApp.java,
│                           # compiles vuln-reader.c SUID binary, sets up SSH
├── healthcheck.sh          # Checks port 8080, flag files, SUID binary existence
├── config/
│   ├── entrypoint.sh       # Generates flags, starts SSH, runs app as appuser
│   ├── VulnApp.java        # Custom HTTP server that logs User-Agent/headers via Log4j
│   ├── log4j2.xml          # Log4j config with ConsoleAppender
│   ├── start-app.sh        # Runs java -cp with JNDI trust flags enabled
│   └── vuln-reader.c       # SUID C binary that reads any file as root (privesc vector)
├── flags/
│   └── generate.sh         # Standalone flag generation script
├── README.md               # Machine card with CVE, difficulty, hints
└── writeup/
    ├── solution.md         # Full walkthrough: nmap → JNDI → shell → SUID → root
    ├── exploit.py          # Working automated exploit (150 lines)
    └── references.md       # CVE links, tools, ATT&CK techniques
```

**Key principle**: The Dockerfile installs the EXACT vulnerable version. The entrypoint creates the privesc path. The exploit.py actually works end-to-end.

---

## 8. FILE COUNTS

| Category | Count |
|----------|-------|
| Total files in project | 487 |
| Total directories | 219 |
| docker-compose.yml files | 42 |
| Escape override composes | 3 |
| Multi-arch override composes | 2 |
| Dockerfiles | 43 |
| Health checks | 42 |
| READMEs | 43 |
| Writeups (solution.md) | 42 |
| Exploit scripts | 42 |
| Reference docs | 42 |
| PoC JS files | 4 |
| BUILD_FROM_SOURCE docs | 4 |
| Documentation files | 8 |
| Infrastructure files | 11 |
| Scripts | ~6 |

---

## 9. KNOWN ISSUES & CLEANUP NEEDED

1. **`scripts/machines/` directory**: The failed bash generator script (`generate-machines.sh`) created a duplicate directory at `scripts/machines/01_WebServer_Runtime/` with files for machines 04-07. This should be DELETED — it's orphaned output from the failed first attempt. The Python generator (`generate-machines.py`) worked correctly and wrote to the proper `machines/` paths.

2. **Machine 02 (SpringBreak)**: Dockerfile references downloading a Tomcat 9.0.60 tarball and a `config/vuln-app/` directory. The vuln-app directory has only a README.md explaining the Spring WAR needs to be built. The actual WAR file download/build step needs to be added.

3. **Machine 03 (PathFinder)**: Dockerfile tries to install Apache 2.4.49 from apt first (which won't work), then falls back to source compilation. The fallback should work but the httpd.conf referenced in the COPY doesn't exist yet.

4. **Portal**: The server.js uses self-signed TLS certs from `/app/certs/` which are generated in the portal Dockerfile at build time. If certs fail, it falls back to HTTP.

---

## 10. RECOMMENDED BUILD ORDER

Start with the easiest machines that have the smallest attack surface:

**Tier 1 (simplest to implement)**:
- 05-ShellShocked (just Apache+CGI+old bash + SUID nmap)
- 25-RedisRaider (just Redis no auth + SSH)
- 06-PHPocalypse (Apache+PHP-CGI + writable cron)
- 13-GrafanLeak (Grafana + path traversal + SQLite)
- 16-ThinkPwned (ThinkPHP + SUID find)
- 32-MinIOLeaker (MinIO server + bucket with SSH key)

**Tier 2 (medium complexity)**:
- 04-StrutsZone, 07-GhostCat, 08-DrupalDoom, 10-BulletProof
- 11-Confluencer, 14-JoomBleed, 15-Ignition, 17-ImageTragick
- 24-ActiveMQtter, 27-ElasticPwn, 28-SolrBlaze
- 37-PwnKit

**Tier 3 (complex — need custom app code)**:
- 18-ProtoPoison, 19-PickleRick, 20-JWTwisted, 22-React2Shell
- 26-MongoMayhem, 29-BigIPwned, 30-CitrixBreaker, 31-IvantiGate

**Tier 4 (very complex — large services or kernel exploits)**:
- 09-PressGrave (WordPress + Docker escape)
- 12-GitLabyrinth (GitLab CE — 2GB+ image)
- 21-WebLogicBmb (Oracle WebLogic)
- 23-JenkinsOwned (Jenkins with credential decryption)
- 33-MOVEitMstr, 34-ApacheNght, 35-GoAnywher
- 36-BaronSamedit, 38-DirtyPipe (kernel exploits in containers)

**Tier 5 (hardest — browser engine binaries)**:
- 39-42 (need pre-built vulnerable V8/JSC binaries)

---

## 11. KEY DESIGN DECISIONS ALREADY MADE

These were resolved in `implementation_plan.md` section "Decisions Log":

| Decision | Resolution |
|----------|-----------|
| Portal style | Simple dashboard + light gamification (no leaderboard) |
| Escape challenges | Gated behind `--enable-escape-challenges` flag |
| Multi-arch | Separate `docker-compose.{arch}.yml` override files |
| Browser binaries | Pre-built via GitHub Releases + BUILD_FROM_SOURCE.md |
| React2Shell (Machine 22) | Added as CVE-2025-55182, Insane difficulty, 100 points |
| Flag format | `FLAG{32_hex_chars}` from SHA256(seed + machine_id) |
| Points | Easy: 10, Medium: 25, Hard: 50, Insane: 100 |
| User flag: 40%, Root flag: 60% of total points |
