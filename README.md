# 🏴 Local-Machine — Self-Hosted Red Team Training Platform

> A **HackTheBox-style server platform** you deploy on your own dedicated server.  
> Players register on the web portal, download a personal `.ovpn` file, connect once, and get full access to **42 isolated challenge machines** built on real Critical/High CVEs.  
> Designed for red team learners who need a **safe, unrestricted environment** — run `nmap`, brute-force, use Metasploit freely. No rate limits. No bans.

---

## 🚀 Quick Start

```bash
# 1. Install k3s (Kubernetes)
curl -sfL https://get.k3s.io | sh -

# 2. Configure
cp .env.example .env
nano .env   # Set SERVER_IP, FLAG_SEED, PORTAL_SECRET

# 3. Initialize OpenVPN CA (one-time)
./infra/vpn/setup-ca.sh

# 4. Start the lab
./run.sh up

# 5. Access the portal
# https://<your-server-ip>:8443
```

---

## 📋 What's Inside

| Category | Machines | Topics |
|----------|----------|--------|
| 🌐 Web Server & Runtime | 01–07 | Log4j, Spring, Apache, Struts, Bash, PHP, Tomcat |
| 📰 CMS & Web Application | 08–14 | Drupal, WordPress, vBulletin, Confluence, GitLab, Grafana, Joomla |
| 📦 Framework & Library | 15–22 | Laravel, ThinkPHP, ImageMagick, Node.js, Python, JWT, WebLogic, React |
| 🏢 Enterprise Middleware | 23–28 | Jenkins, ActiveMQ, Redis, MongoDB, Elasticsearch, Solr |
| 🔌 Network Appliance & Proxy | 29–32 | F5 BIG-IP, Citrix, Ivanti, MinIO |
| 📁 Data & File Transfer | 33–35 | MOVEit, Apache Proxy, GoAnywhere |
| ⬆️ Privilege Escalation | 36–38 | sudo (Baron Samedit), polkit (PwnKit), kernel (Dirty Pipe) |
| 💀 Advanced Exploitation | 39–42 | V8 JIT, WebKit/JSC, ARM shellcode, sandbox escape |

---

## 🔒 Security Model

| Layer | Mechanism |
|-------|-----------|
| **Per-user isolation** | Each player gets a dedicated Kubernetes namespace — zero cross-user traffic |
| **Dynamic Pod IPs** | Each machine spawn gets a unique IP; portal displays it live; no routing conflict |
| **NetworkPolicy** | Default-deny per namespace; only the player's VPN IP is allowed in |
| **Ephemeral storage** | All machine state wiped on Pod death — no data leaks between sessions |
| **Unique flags** | `sha256(FLAG_SEED + USER_ID + MACHINE_ID)` — flag sharing between players doesn't work |
| **Escape challenge isolation** | Docker/container escape machines run under **Kata Containers (Firecracker)** — escape lands in a microVM, never on the host |
| **Auto-recovery** | Portal detects crashed Pods on page refresh and auto-respawns them |

---

## 🏗️ Architecture

```
Player → register on portal → download .ovpn → sudo openvpn user.ovpn
       → dashboard → Spawn machine → Pod starts in ns:user-<name>
       → portal shows Pod IP → hack away
       → submit flag → earn points

Kubernetes Cluster:
  ns:user-alice  [one Pod, dynamic IP]   ← alice's machine
  ns:user-bob    [one Pod, dynamic IP]   ← bob's machine
  (NetworkPolicy: namespaces are fully isolated)

Escape challenges → Kata Firecracker runtime → escape lands in microVM, not host
```

---

## 📖 Documentation

- [Setup Guide](docs/01_SETUP.md) — k3s, OpenVPN CA, Kata Containers, portal install
- [Architecture](docs/02_ARCHITECTURE.md) — k8s topology, isolation model, security layers
- [Admin Guide](docs/03_ADMIN_GUIDE.md) — manage users, Pods, VPN peers, escape challenges
- [Player Guide](docs/04_PLAYER_GUIDE.md) — register, connect, hack, submit flags
- [MITRE ATT&CK Map](docs/MITRE_ATTACK_MAP.md)

---

## 🎮 Platform Features

- 🔐 **Web registration** — players sign up, portal auto-provisions their k8s namespace
- 📥 **OVPN download** — one `.ovpn` file from profile page, one command to connect
- 🖱️ **Spawn button** — one-click machine start, IP shown immediately
- 🔄 **Refresh-to-fix** — broken machine? refresh the page, portal auto-respawns it
- 🏴 **Flag submission** — per-user unique flags, submit via dashboard
- ⚡ **Points & Ranks** — Easy: 10, Medium: 25, Hard: 50, Insane: 100
- 🩸 **First blood badges** — first player to root each machine
- 📊 **Leaderboard & Activity feed** — CTFd-style live activity

---

## 🛠️ Admin CLI

```bash
./run.sh up                    # Start the lab (VPN + portal + k3s)
./run.sh down                  # Stop everything
./run.sh status                # Live Pod status per user
./run.sh health 01             # Health check machine 01
./run.sh logs 01               # View machine 01 logs
./scripts/add-peer.sh alice    # Generate alice.ovpn
./scripts/revoke-peer.sh alice # Revoke alice's VPN access
```

---

## 📜 License

MIT License — See [LICENSE](LICENSE)

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

---

# Development on this repository has been suspended because the development strategy has shifted from using Docker to issuing multi-VM instances and managing them by linking the issued VMs via SPNs.
## For more details on this change, please refer to https://attackevals.github.io/ael/.
