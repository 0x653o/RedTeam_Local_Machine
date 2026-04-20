# 📋 01_WebServer_Runtime — Implementation Plan

> **Scope**: Machines 01–07 | Fix Log4j errors, complete PARTIAL machines, implement SCAFFOLDED machines.
> **Goal**: All 7 machines build, start, and are fully exploitable as isolated Docker services.

---

## Priority Queue

| Priority | Machine | Action | Effort |
|----------|---------|--------|--------|
| P0 | 01-log4hell | Fix JDK version (8) + bundle JARs locally | Low |
| P1 | 05-shellshocked | Fix CGI config + replace SUID nmap with custom binary | Low |
| P1 | 04-strutszone | Fix archive URLs + write real exploit.py | Medium |
| P2 | 06-phpocalypse | Full implementation from scratch | High |
| P2 | 07-ghostcat | Full implementation from scratch | High |

---

## §1 Machine 01 — Log4Hell Fixes

### 1.1 Switch to JDK 8 (Required for JNDI RCE)

Change `FROM ubuntu:22.04` to use JDK 8. JDK 11+ ignores `trustURLCodebase` making JNDI RCE impossible without a deserialization gadget chain. JDK 8 works with the simple LDAP redirect.

**Dockerfile change**:
```dockerfile
# BEFORE
RUN apt-get install -y openjdk-11-jdk-headless

# AFTER
RUN apt-get install -y openjdk-8-jdk-headless
```

### 1.2 Bundle JARs Locally

Add Log4j JARs to `config/lib/` in the repo. Remove wget from Dockerfile:
```dockerfile
COPY config/lib/log4j-core-2.14.1.jar /opt/webapp/lib/
COPY config/lib/log4j-api-2.14.1.jar  /opt/webapp/lib/
```

### 1.3 Add JNDI Enable Flag

Append to `start-app.sh`:
```bash
-Dlog4j2.enableJndi=true \
```

---

## §2 Machine 04 — StrutsZone Fixes

### 2.1 Use vulhub Base Image (Reliable)

Replace the brittle wget-based Dockerfile:
```dockerfile
FROM vulhub/struts2:s2-045
# already has Tomcat + Struts2 2.3.31 showcase WAR deployed
```

Or use a Docker Hub image: `piesecurity/apache-struts2-cve-2017-5638`

### 2.2 Real exploit.py

CVE-2017-5638 OGNL injection via `Content-Type` header.

### 2.3 Healthcheck update

Verify Struts2 showcase responds at `/struts2-showcase/`.

---

## §3 Machine 05 — ShellShocked Fixes

### 3.1 Fix CGI Config Activation

Add to `config/setup.sh`:
```bash
a2enconf serve-cgi-bin
```

### 3.2 Replace SUID nmap with Custom Binary

Modern nmap (>5.21) removed `--interactive`. Compile a `file-reader` SUID binary instead (same as Machine 01's `vuln-reader.c`). Player uses it to read `/root/root.txt`.

### 3.3 Fix Bash 4.3 Build  

Use snapshot.debian.org old package instead of compiling from source:
```dockerfile
RUN wget -q "https://snapshot.debian.org/archive/debian/20140911T220313Z/pool/main/b/bash/bash_4.3-9_amd64.deb" \
    -O /tmp/bash43.deb && dpkg -i /tmp/bash43.deb || true
```
Or keep compile but add apt build-dep to speed it up.

---

## §4 Machine 06 — PHPocalypse (Full Implementation)

**CVE-2012-1823**: PHP-CGI argument injection → RCE → writable cron → root.

### 4.1 Dockerfile Plan

```dockerfile
FROM ubuntu:20.04
# Install: apache2, php5.6 (from ondrej/php PPA), libapache2-mod-php
# PHP-CGI must be exposed via Apache mod_actions
# Enable: a2enmod cgi actions
```

Since Ubuntu 20.04 only ships PHP 7.4+, we use `ppa:ondrej/php` for PHP 5.6.

### 4.2 Apache Config

Route requests so PHP files go through `php-cgi` binary directly (not mod_php):
```apache
Action php-cgi /cgi-bin/php-cgi
AddHandler php-cgi .php
```

The query-string injection `?-d+allow_url_include=1+-d+auto_prepend_file=php://input` passes flags to `php-cgi` binary.

### 4.3 Setup Script

```bash
# Writable cron script owned by www-data but executed as root
echo "* * * * * root /opt/scripts/backup.sh" >> /etc/crontab
echo "#!/bin/bash" > /opt/scripts/backup.sh
chmod 777 /opt/scripts/backup.sh  # www-data can write to it
```

### 4.4 Kill Chain

```
nmap → port 80 → index.php detected → ?-s leaks PHP source
→ ?-d+allow_url_include=1+-d+auto_prepend_file=php://input POST with PHP code
→ RCE as www-data → discover /opt/scripts/backup.sh (777)
→ write reverse shell to backup.sh → wait for cron → root shell
```

---

## §5 Machine 07 — GhostCat (Full Implementation)

**CVE-2020-1938**: Tomcat AJP file read → WEB-INF/web.xml leaks creds → Manager WAR deploy → root.

### 5.1 Dockerfile Plan

```dockerfile
FROM ubuntu:22.04
# Install: openjdk-11-jdk-headless, openssh-server
# Download Tomcat 9.0.30 (last version before AJP was disabled by default)
# Configure AJP connector on port 8009
# Deploy a sample webapp with creds in WEB-INF/web.xml
# Enable Tomcat Manager with admin credentials
```

### 5.2 server.xml AJP Config

```xml
<Connector protocol="AJP/1.3"
           address="0.0.0.0"
           port="8009"
           redirectPort="8443"
           secretRequired="false" />
```

AJP is disabled by default in Tomcat 9.0.31+, which is why we pin 9.0.30.

### 5.3 web.xml Credential Leak

The target file players read via Ghostcat:
```xml
<init-param>
  <param-name>adminPassword</param-name>
  <param-value>TomcatAdmin2020!</param-value>
</init-param>
```

### 5.4 Tomcat Manager → WAR RCE

After reading creds via AJP file-read, player authenticates to `/manager/text/` and deploys a JSP webshell WAR.

### 5.5 Setup Script

```bash
# Root SSH enabled, authorized_keys approach
# OR sudo miscfg for tomcat user
echo "tomcat ALL=(ALL) NOPASSWD: /usr/bin/find" >> /etc/sudoers.d/tomcat
```

### 5.6 docker-compose.yml Update

Must expose port 8009 on the internal network:
```yaml
# No external port exposure — but AJP must be accessible via VPN IP
networks:
  machine_07_net:
    ipv4_address: 10.10.7.10
```
Both port 8009 (AJP) and 8080 (HTTP) are internally accessible.

---

## §6 Isolation Model (All Machines)

Every machine MUST:
1. Use its own `bridge` network (`10.10.N.0/24`)
2. Set `internal: true` on the network after build (prevents container internet access)
3. Use `mem_limit`, `cpus`, `pids_limit` resource caps
4. Have a working `healthcheck.sh`
5. Never share volumes or networks with other machines

---

## §7 File Generation Order

Execute in this order to avoid dependency issues:

```
Step 1: Fix 01-log4hell  (Dockerfile + start-app.sh)
Step 2: Fix 05-shellshocked (setup.sh + vuln-suid.c + Dockerfile)
Step 3: Fix 04-strutszone (Dockerfile + exploit.py + solution.md)
Step 4: Implement 06-phpocalypse (all new files)
Step 5: Implement 07-ghostcat (all new files)
Step 6: Write implementation_plan.md (this file — done)
Step 7: Update project_status.md when each machine reaches DEEP
```

---

## §8 Verification Plan

```bash
BASE=machines/01_WebServer_Runtime

# Build and run each machine individually
for m in 01-log4hell 02-springbreak 03-pathfinder 04-strutszone 05-shellshocked 06-phpocalypse 07-ghostcat; do
  echo "=== Testing $m ==="
  docker compose -f $BASE/$m/docker-compose.yml up -d --build
  sleep 30
  docker inspect lm-$(echo $m | cut -d- -f1)-$(echo $m | cut -d- -f2-) \
    --format '{{ .State.Health.Status }}'
  docker compose -f $BASE/$m/docker-compose.yml down
done
```
