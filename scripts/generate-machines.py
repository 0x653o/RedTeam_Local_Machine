#!/usr/bin/env python3
"""Generate all machine files from definitions."""
import os
import stat

PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

MACHINES = [
    # (id, name, cve, cvss, cat_dir, port, difficulty, points, desc, killchain, attack, privesc, base_img)
    (4, "strutszone", "CVE-2017-5638", "10.0", "01_WebServer_Runtime", 8080, "Medium", 25, "Apache Struts2 OGNL injection via Content-Type header", "nmap -> Struts2 8080 -> OGNL Content-Type injection -> RCE as tomcat -> sudo miscfg -> root", "T1190,T1059.004,T1548.003", "Misconfigured sudo", "ubuntu:22.04"),
    (5, "shellshocked", "CVE-2014-6271", "10.0", "01_WebServer_Runtime", 80, "Easy", 10, "Bash Shellshock via CGI + SUID nmap", "nmap -> Apache CGI 80 -> Shellshock User-Agent -> Shell -> SUID nmap interactive -> root", "T1190,T1059.004,T1548.001", "SUID nmap --interactive", "ubuntu:20.04"),
    (6, "phpocalypse", "CVE-2012-1823", "9.8", "01_WebServer_Runtime", 80, "Easy", 10, "PHP-CGI argument injection into RCE via writable cron", "nmap -> PHP-CGI 80 -> ?-s leaks source -> argument injection RCE -> writable cron -> root", "T1190,T1053.003", "Writable cron script", "ubuntu:20.04"),
    (7, "ghostcat", "CVE-2020-1938", "9.8", "01_WebServer_Runtime", 8080, "Medium", 25, "Tomcat AJP Ghostcat file read into Manager WAR deploy", "nmap -> AJP 8009 + HTTP 8080 -> Ghostcat WEB-INF read -> admin creds -> WAR deploy -> root", "T1190,T1552.001", "WAR shell deployment", "ubuntu:22.04"),
    (8, "drupaldoom", "CVE-2018-7600", "9.8", "02_CMS_WebApp", 80, "Medium", 25, "Drupalgeddon2 Form API RCE with MySQL cred reuse", "nmap -> Drupal 80 -> Drupalgeddon2 RCE -> MySQL creds settings.php -> admin hash crack -> su sudo -> root", "T1190,T1552.001,T1548.003", "Credential reuse + sudo", "ubuntu:22.04"),
    (9, "pressgrave", "CVE-2022-0739", "9.8", "02_CMS_WebApp", 80, "Hard", 50, "WordPress SQLi into theme editor RCE and Docker socket escape", "wpscan -> WordPress 80 -> Plugin SQLi -> hash dump -> theme editor RCE -> Docker socket escape -> host root", "T1190,T1003.003,T1611", "Docker socket escape", "ubuntu:22.04"),
    (10, "bulletproof", "CVE-2019-16759", "9.8", "02_CMS_WebApp", 80, "Medium", 25, "vBulletin widgetConfig pre-auth RCE into hidden cronjob", "nmap -> vBulletin 80 -> widgetConfig RCE -> discover hidden cronjob -> write cron path -> root", "T1190,T1053.003", "Hidden cronjob hijack", "ubuntu:22.04"),
    (11, "confluencer", "CVE-2022-26134", "9.8", "02_CMS_WebApp", 8090, "Medium", 25, "Confluence OGNL injection with SSH key reuse", "nmap -> Confluence 8090 -> OGNL URL injection -> RCE -> SSH key in home -> key reuse for root -> root", "T1190,T1021.004", "SSH key reuse", "ubuntu:22.04"),
    (12, "gitlabyrinth", "CVE-2021-22205", "10.0", "02_CMS_WebApp", 80, "Hard", 50, "GitLab ExifTool RCE into Rails console root SSH key", "nmap -> GitLab 80 -> DjVu ExifTool upload -> RCE as git -> Rails console reset -> root SSH key repo -> root", "T1190,T1059.004", "GitLab Rails console", "ubuntu:22.04"),
    (13, "grafanleak", "CVE-2021-43798", "7.5", "02_CMS_WebApp", 3000, "Easy", 10, "Grafana path traversal into SQLite cred leak SSH spray", "nmap -> Grafana 3000 -> plugin path traversal -> read config -> SQLite download -> extract creds -> SSH -> root", "T1190,T1552.001,T1021.004", "Credential spray via SSH", "ubuntu:22.04"),
    (14, "joombleed", "CVE-2023-23752", "7.5", "02_CMS_WebApp", 80, "Easy", 10, "Joomla API info leak into DB creds template editor RCE", "nmap -> Joomla 80 -> API info leak -> DB creds -> admin login -> template editor PHP -> sudo miscfg -> root", "T1190,T1552.001,T1505.003", "Sudo misconfiguration", "ubuntu:22.04"),
    (15, "ignition", "CVE-2021-3129", "9.8", "03_Framework_Library", 80, "Medium", 25, "Laravel Ignition debug page phar file write RCE", "gobuster -> Laravel debug -> Ignition execute-solution -> phar file write -> RCE -> root SSH key /opt -> root", "T1190,T1021.004", "SSH key discovery", "ubuntu:22.04"),
    (16, "thinkpwned", "CVE-2018-20062", "9.8", "03_Framework_Library", 80, "Easy", 10, "ThinkPHP invokefunction RCE with SUID find", "nmap -> ThinkPHP 80 -> invokefunction controller -> RCE -> SUID find -> find -exec sh -> root", "T1190,T1548.001", "SUID find binary", "ubuntu:22.04"),
    (17, "imagetragick", "CVE-2016-3714", "8.4", "03_Framework_Library", 80, "Medium", 25, "ImageMagick MVG command injection cron root processing", "nmap -> image upload 80 -> MVG file cmd injection -> shell -> cron ImageMagick root -> poison input -> root", "T1190,T1053.003", "Cron ImageMagick processing", "ubuntu:22.04"),
    (18, "protopoison", "CWE-1321", "9.8", "03_Framework_Library", 3000, "Hard", 50, "Node.js prototype pollution into EJS SSTI RCE", "nmap -> Node.js API 3000 -> fuzz JSON -> __proto__ pollution -> EJS template options -> SSTI -> RCE -> root", "T1190,T1059.007", "Container runs as root", "node:18-slim"),
    (19, "picklerick", "CWE-502", "9.8", "03_Framework_Library", 5000, "Hard", 50, "Python pickle deserialization Redis pivot SSH key", "nmap -> Python 5000 -> decode session cookie -> pickle format -> malicious pickle -> RCE -> Redis -> SSH key -> root", "T1190,T1021.006", "Redis lateral movement", "python:3.11-slim"),
    (20, "jwtwisted", "CVE-2022-21449", "9.8", "03_Framework_Library", 8080, "Hard", 50, "Java JWT algorithm confusion admin SSRF internal RCE", "nmap -> Java API 8080 -> capture JWT -> algorithm confusion -> forge admin -> SSRF -> internal service -> RCE -> root", "T1190,T1550.001,T1090", "SSRF to internal service", "ubuntu:22.04"),
    (21, "weblogicbmb", "CVE-2019-2725", "9.8", "03_Framework_Library", 7001, "Medium", 25, "WebLogic XMLDecoder deserialization already root", "nmap -> WebLogic 7001 -> T3/IIOP -> XMLDecoder /_async -> RCE -> already root in container -> root", "T1190,T1059.004", "Container runs as root", "ubuntu:22.04"),
    (22, "react2shell", "CVE-2025-55182", "10.0", "03_Framework_Library", 3000, "Insane", 100, "Next.js RSC Flight protocol deserialization env pivot PostgreSQL SSH", "nmap -> Next.js 3000 -> RSC Flight endpoint -> crafted serialized payload -> RCE node -> process.env -> DB creds -> PostgreSQL SSH keys -> sudo miscfg -> root", "T1190,T1059.007,T1021.004", "Database credential pivot", "node:20"),
    (23, "jenkinsowned", "CVE-2024-23897", "9.8", "04_Enterprise_Middleware", 8080, "Hard", 50, "Jenkins CLI file read decrypt SSH credentials", "nmap -> Jenkins 8080 -> CLI argument file read -> leak master.key -> decrypt SSH creds -> SSH root -> root", "T1190,T1552.004,T1021.004", "Jenkins credential decryption", "ubuntu:22.04"),
    (24, "activemqtter", "CVE-2023-46604", "10.0", "04_Enterprise_Middleware", 8161, "Medium", 25, "ActiveMQ ClassInfo deserialization sudo escape", "nmap -> ActiveMQ 61616+8161 -> ClassInfo ExceptionResponse deser -> RCE -> sudo escape -> root", "T1190,T1548.003", "Service account sudo", "ubuntu:22.04"),
    (25, "redisraider", "Miscfg", "9.8", "04_Enterprise_Middleware", 6379, "Easy", 10, "Redis no auth SSH key write", "nmap -> Redis 6379 no auth -> CONFIG SET dir /root/.ssh -> write authorized_keys -> SSH root -> root", "T1190,T1098.004,T1053.003", "Redis SSH key write", "ubuntu:22.04"),
    (26, "mongomayhem", "Miscfg+NoSQLi", "9.1", "04_Enterprise_Middleware", 80, "Medium", 25, "MongoDB no auth webapp admin creds NoSQLi RCE", "nmap -> MongoDB 27017 + webapp 80 -> dump users collection -> admin creds -> NoSQLi admin -> RCE -> root", "T1190,T1552.001,T1550.001", "NoSQLi command injection", "ubuntu:22.04"),
    (27, "elasticpwn", "CVE-2015-1427", "9.8", "04_Enterprise_Middleware", 9200, "Medium", 25, "Elasticsearch Groovy script sandbox escape", "nmap -> ES 9200 -> Groovy script _search -> sandbox escape -> RCE -> config cred reuse -> root", "T1190,T1552.001", "Credential reuse", "ubuntu:22.04"),
    (28, "solrblaze", "CVE-2019-17558", "9.8", "04_Enterprise_Middleware", 8983, "Medium", 25, "Solr Velocity template injection", "nmap -> Solr 8983 -> Velocity template injection -> RCE -> SSH creds in logs -> SSH root -> root", "T1190,T1552.001,T1021.004", "Log credential leak", "ubuntu:22.04"),
    (29, "bigipwned", "CVE-2022-1388", "9.8", "05_NetworkAppliance_Proxy", 443, "Medium", 25, "F5 BIG-IP header auth bypass iControl REST RCE", "nmap -> BIG-IP 443 -> header auth bypass -> iControl REST -> RCE -> already root -> root", "T1190,T1071.001", "Already root in appliance", "ubuntu:22.04"),
    (30, "citrixbreaker", "CVE-2019-19781", "9.8", "05_NetworkAppliance_Proxy", 443, "Hard", 50, "Citrix ADC path traversal Perl template RCE", "nmap -> Citrix 443 -> path traversal -> write Perl template -> trigger -> webshell -> RCE -> root", "T1190,T1505.003", "Template injection", "ubuntu:22.04"),
    (31, "ivantigate", "CVE-2024-21887", "9.1", "05_NetworkAppliance_Proxy", 443, "Hard", 50, "Ivanti Connect Secure auth bypass cmd injection", "nmap -> Ivanti 443 -> auth bypass chain -> command injection -> RCE -> already root -> root", "T1190,T1059.004", "Already root in appliance", "ubuntu:22.04"),
    (32, "minioleaker", "CVE-2023-28432", "9.8", "05_NetworkAppliance_Proxy", 9000, "Easy", 10, "MinIO env var leak S3 keys SSH key in bucket", "nmap -> MinIO 9000 -> /minio/health/cluster env leak -> S3 keys -> SSH key in bucket -> SSH -> root", "T1190,T1552.001,T1021.004", "S3 bucket credential leak", "ubuntu:22.04"),
    (33, "moveitmstr", "CVE-2023-34362", "9.8", "06_Data_FileTransfer", 443, "Hard", 50, "MOVEit Transfer SQLi session hijack deser RCE", "nmap -> MOVEit 443 -> SQLi session handling -> extract tokens -> impersonate sysadmin -> deser RCE -> root", "T1190,T1003.003", "Deserialization chain", "ubuntu:22.04"),
    (34, "apachenght", "CVE-2023-25690", "9.8", "06_Data_FileTransfer", 80, "Hard", 50, "Apache reverse proxy HTTP request smuggling", "nmap -> Apache proxy 80 -> request smuggling -> bypass auth -> management API -> RCE -> root", "T1190,T1036.005", "Request smuggling", "ubuntu:22.04"),
    (35, "goanywher", "CVE-2023-0669", "9.8", "06_Data_FileTransfer", 8000, "Hard", 50, "GoAnywhere MFT AES deserialization RCE", "nmap -> GoAnywhere 8000 -> License portal -> AES deser -> blind deser -> RCE -> root", "T1190,T1059.004", "Java deserialization", "ubuntu:22.04"),
    (36, "baronsamedit", "CVE-2021-3156", "7.8", "07_Privilege_Escalation", 80, "Hard", 50, "PHP upload webshell sudo heap overflow", "nmap -> PHP upload 80 -> webshell -> low shell -> sudo 1.8.x -> heap overflow sudoedit -s -> root", "T1190,T1068", "sudo heap buffer overflow", "ubuntu:20.04"),
    (37, "pwnkit", "CVE-2021-4034", "7.8", "07_Privilege_Escalation", 5000, "Medium", 25, "Python webapp SSTI polkit pkexec exploit", "nmap -> Python 5000 -> Jinja2 SSTI -> low shell -> polkit pkexec env var injection -> root", "T1190,T1068", "pkexec env variable injection", "ubuntu:20.04"),
    (38, "dirtypipe", "CVE-2022-0847", "7.8", "07_Privilege_Escalation", 80, "Hard", 50, "SSRF internal SSTI kernel splice pipe exploit", "nmap -> SSRF 80 -> internal webapp -> SSTI -> low shell -> /etc/passwd overwrite via splice -> root", "T1190,T1090,T1068", "Kernel splice pipe bug", "ubuntu:22.04"),
    (39, "v8-maprem", "CVE-2018-17463", "8.8", "08_Advanced_Exploitation", 9999, "Hard", 50, "V8 CheckMaps elimination type confusion shellcode", "nmap -> d8 REPL 9999 -> JIT CheckMaps skip -> type confusion -> addrof/fakeobj -> arb R/W -> Wasm RWX shellcode", "T1190,T1203", "V8 JIT exploitation", "ubuntu:22.04"),
    (40, "v8-turboconf", "CVE-2020-6418", "8.8", "08_Advanced_Exploitation", 9999, "Insane", 100, "V8 TurboFan type confusion OOB shellcode", "nmap -> d8 REPL 9999 -> TurboFan JSCreate side-effect -> OOB array -> corrupt ArrayBuffer -> arb R/W -> shellcode", "T1190,T1203", "V8 TurboFan exploitation", "ubuntu:22.04"),
    (41, "v8-oobarray", "CVE-2021-30632", "8.8", "08_Advanced_Exploitation", 9999, "Insane", 100, "V8 TurboFan OOB write sandbox bypass shellcode", "nmap -> d8 REPL 9999 -> TurboFan range analysis -> JSArray length corrupt -> leak compressed ptrs -> sandbox bypass", "T1190,T1203", "V8 sandbox bypass", "ubuntu:22.04"),
    (42, "jsc-jitrce", "CVE-2020-9802", "8.8", "08_Advanced_Exploitation", 9999, "Insane", 100, "WebKit DFG JIT structure spray RWX shellcode", "nmap -> jsc REPL 9999 -> DFG JIT opt bug -> addrof/fakeobj -> structure ID spray -> JIT RWX -> shellcode", "T1190,T1203", "WebKit DFG exploitation", "ubuntu:22.04"),
]

def gen_compose(m):
    mid, name, cve, cvss, cat, port, diff, pts, desc, kc, atk, priv, img = m
    pid = f"{mid:02d}"
    return f"""services:
  {name}:
    build: {{ context: ., dockerfile: Dockerfile }}
    container_name: lm-{pid}-{name}
    hostname: {name}
    environment: [ "FLAG_SEED=${{FLAG_SEED:-default-seed}}", "MACHINE_ID={pid}" ]
    networks: {{ machine_{pid}_net: {{ ipv4_address: 10.10.{mid}.10 }} }}
    restart: unless-stopped
    mem_limit: 512m
    cpus: 1.0
    pids_limit: 256
    security_opt: [ "no-new-privileges:false" ]
    healthcheck: {{ test: ["CMD-SHELL", "/healthcheck.sh"], interval: 30s, timeout: 10s, retries: 3, start_period: 60s }}

networks:
  machine_{pid}_net:
    driver: bridge
    ipam: {{ config: [{{ subnet: 10.10.{mid}.0/24, gateway: 10.10.{mid}.1 }}] }}
"""

def gen_dockerfile(m):
    mid, name, cve, cvss, cat, port, diff, pts, desc, kc, atk, priv, img = m
    pid = f"{mid:02d}"
    extra = ""
    if "node:" in img:
        extra = "RUN apt-get update 2>/dev/null || true; apt-get install -y procps net-tools curl 2>/dev/null || apk add --no-cache procps net-tools curl 2>/dev/null || true\nRUN adduser --disabled-password --gecos '' user 2>/dev/null || useradd -m user 2>/dev/null || true"
    elif "python:" in img:
        extra = "RUN apt-get update && apt-get install -y procps net-tools curl openssh-server sudo iproute2 && rm -rf /var/lib/apt/lists/*\nRUN useradd -m -s /bin/bash user"
    else:
        extra = "RUN apt-get update && apt-get install -y curl wget netcat-openbsd net-tools iproute2 openssh-server sudo vim procps cron && rm -rf /var/lib/apt/lists/*\nRUN useradd -m -s /bin/bash user"
    return f"""# Machine {pid}: {name} -- {cve} (CVSS {cvss})
# {desc}
FROM {img}
ENV DEBIAN_FRONTEND=noninteractive
{extra}

COPY config/ /opt/config/
COPY config/entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh
COPY flags/generate.sh /opt/generate-flags.sh
RUN chmod +x /entrypoint.sh /healthcheck.sh /opt/generate-flags.sh 2>/dev/null || true

EXPOSE {port}
ENTRYPOINT ["/entrypoint.sh"]
"""

def gen_entrypoint(m):
    return """#!/bin/bash
set -e
SEED="${FLAG_SEED:-default-seed}"
MID="${MACHINE_ID:-00}"
ROOT_FLAG=$(echo -n "${SEED}:machine_${MID}" | sha256sum | cut -c1-32)
USER_FLAG=$(echo -n "${SEED}:user_${MID}" | sha256sum | cut -c1-32)
echo "FLAG{${ROOT_FLAG}}" > /root/root.txt; chmod 400 /root/root.txt
mkdir -p /home/user
echo "FLAG{${USER_FLAG}}" > /home/user/user.txt
chown user:user /home/user/user.txt 2>/dev/null || true; chmod 444 /home/user/user.txt
mkdir -p /var/run/sshd; ssh-keygen -A 2>/dev/null || true
/usr/sbin/sshd 2>/dev/null &
[ -f /opt/config/setup.sh ] && chmod +x /opt/config/setup.sh && /opt/config/setup.sh
echo "[*] Machine ${MID} starting..."
if [ -f /opt/config/start-service.sh ]; then
    chmod +x /opt/config/start-service.sh; exec /opt/config/start-service.sh
else
    tail -f /dev/null
fi
"""

def gen_healthcheck(m):
    mid, name, cve, cvss, cat, port, diff, pts, desc, kc, atk, priv, img = m
    pid = f"{mid:02d}"
    return f"""#!/bin/bash
# Health check for machine {pid}: {name}
check_ok=true
if ! ss -tlnp 2>/dev/null | grep -q ":{port} "; then
    echo "[UNHEALTHY] Port {port} not listening"; check_ok=false
fi
[ -f /root/root.txt ] || {{ echo "[UNHEALTHY] Root flag missing"; check_ok=false; }}
[ -f /home/user/user.txt ] || {{ echo "[UNHEALTHY] User flag missing"; check_ok=false; }}
if [ "$check_ok" = true ]; then echo "[HEALTHY] All checks passed"; exit 0; else exit 1; fi
"""

def gen_flags(m):
    mid = m[0]; pid = f"{mid:02d}"
    return f"""#!/bin/bash
SEED="${{FLAG_SEED:-default-seed}}"; MID="{pid}"
echo "FLAG{{$(echo -n "${{SEED}}:machine_${{MID}}" | sha256sum | cut -c1-32)}}" > /root/root.txt; chmod 400 /root/root.txt
mkdir -p /home/user; echo "FLAG{{$(echo -n "${{SEED}}:user_${{MID}}" | sha256sum | cut -c1-32)}}" > /home/user/user.txt
chown user:user /home/user/user.txt 2>/dev/null; chmod 444 /home/user/user.txt
"""

def gen_readme(m):
    mid, name, cve, cvss, cat, port, diff, pts, desc, kc, atk, priv, img = m
    pid = f"{mid:02d}"
    return f"""# Machine {pid}: {name}

| Field | Value |
|-------|-------|
| **CVE** | {cve} |
| **CVSS** | {cvss} |
| **Category** | {cat.replace('_', ' ')} |
| **Difficulty** | {diff} |
| **Points** | {pts} |
| **IP** | 10.10.{mid}.10 |
| **Port** | {port} |

## Description
{desc}

## Kill Chain
```
{kc}
```

## MITRE ATT&CK
{atk}

## Privilege Escalation
{priv}

<details><summary>Hint 1</summary>Start with nmap. What's on port {port}?</details>
<details><summary>Hint 2</summary>Research {cve}.</details>
<details><summary>Hint 3</summary>{priv}</details>
"""

def gen_solution(m):
    mid, name, cve, cvss, cat, port, diff, pts, desc, kc, atk, priv, img = m
    pid = f"{mid:02d}"
    return f"""# Machine {pid}: {name} -- {cve} Walkthrough

## Overview
- **CVE**: {cve} (CVSS {cvss})
- **Kill Chain**: {kc}

## Step 1: Reconnaissance
```bash
nmap -sC -sV -p- 10.10.{mid}.10
# Port {port} open
```

## Step 2: Enumeration
Identify the vulnerable service on port {port}. Research {cve}.

## Step 3: Exploitation
```bash
python3 exploit.py --target 10.10.{mid}.10 --port {port}
cat /home/user/user.txt  # User flag
```

## Step 4: Privilege Escalation
Method: {priv}
```bash
# After escalation:
cat /root/root.txt  # Root flag
```
"""

def gen_exploit(m):
    mid, name, cve, cvss, cat, port, diff, pts, desc, kc, atk, priv, img = m
    pid = f"{mid:02d}"
    return f'''#!/usr/bin/env python3
"""Machine {pid}: {name} -- {cve} Exploit
CVSS: {cvss} | {desc}
"""
import argparse, requests, sys

def exploit(target: str, port: int = {port}):
    url = f"http://{{target}}:{{port}}"
    print(f"[*] Targeting {{url}}")
    print(f"[*] CVE: {cve}")
    print(f"[*] {desc}")
    # TODO: Implement {cve} exploitation payload
    print("[!] See writeup/solution.md for manual steps")

if __name__ == "__main__":
    p = argparse.ArgumentParser(description="{name} -- {cve}")
    p.add_argument("--target", "-t", required=True)
    p.add_argument("--port", "-p", type=int, default={port})
    args = p.parse_args()
    exploit(args.target, args.port)
'''

def gen_references(m):
    mid, name, cve, cvss, cat, port, diff, pts, desc, kc, atk, priv, img = m
    pid = f"{mid:02d}"
    atk_links = "\n".join(f"- [{t}](https://attack.mitre.org/techniques/{t.replace('.', '/')}/)" for t in atk.split(","))
    return f"""# Machine {pid}: {name} -- References
## CVE
- [{cve}](https://nvd.nist.gov/vuln/detail/{cve}) -- CVSS {cvss}
## MITRE ATT&CK
{atk_links}
## Priv Esc: {priv}
"""

for m in MACHINES:
    mid, name = m[0], m[1]
    pid = f"{mid:02d}"
    cat = m[4]
    mdir = os.path.join(PROJECT_DIR, "machines", cat, f"{pid}-{name}")
    
    for d in ["config", "flags", "writeup"]:
        os.makedirs(os.path.join(mdir, d), exist_ok=True)
    
    files = {
        "docker-compose.yml": gen_compose(m),
        "Dockerfile": gen_dockerfile(m),
        "config/entrypoint.sh": gen_entrypoint(m),
        "healthcheck.sh": gen_healthcheck(m),
        "flags/generate.sh": gen_flags(m),
        "README.md": gen_readme(m),
        "writeup/solution.md": gen_solution(m),
        "writeup/exploit.py": gen_exploit(m),
        "writeup/references.md": gen_references(m),
    }
    
    for fname, content in files.items():
        fpath = os.path.join(mdir, fname)
        with open(fpath, "w") as f:
            f.write(content)
        if fname.endswith(".sh") or fname.endswith(".py"):
            os.chmod(fpath, os.stat(fpath).st_mode | stat.S_IEXEC | stat.S_IXGRP | stat.S_IXOTH)
    
    print(f"  [OK] {pid}-{name} ({m[2]})")

print(f"\nDone! Generated {len(MACHINES)} machines.")
