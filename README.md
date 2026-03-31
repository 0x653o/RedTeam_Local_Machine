# 🏴 Local-Machine — Advanced Red Team Lab

> **42 isolated, multi-step challenge machines** built on critical/high-severity CVEs.  
> Each machine enforces a realistic **MITRE ATT&CK kill chain** where every step is a hard dependency for the next.  
> Inspired by **DEFCON CTF Finals, HITCON CTF Finals, BlackHat CTF Finals**.

---

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/your-org/Local-Machine.git
cd Local-Machine

# 2. Configure your lab
cp .env.example .env
nano .env  # Set FLAG_SEED and PORTAL_SECRET

# 3. Generate flags
./scripts/generate-all-flags.sh

# 4. Start the lab
./run.sh up

# 5. Access the dashboard
# https://localhost:8443
```

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

## 🔒 Security Model

- **Network Isolation**: Each machine runs in its own Docker bridge network (`10.10.{N}.0/24`)
- **No Shared State**: Machines cannot communicate with each other
- **Deterministic Flags**: Flags are generated from `FLAG_SEED` — change the seed, change all flags
- **Auto-Recovery**: Lifecycle manager resets machines every 60 minutes
- **Escape Challenges**: Docker/container escapes are **gated** behind `--enable-escape-challenges` flag

## 🏗️ Architecture

```
Player VPN ──▶ WireGuard Gateway ──▶ Docker Bridge Router ──▶ 42 Isolated Machines
                                  ──▶ Web Portal (Dashboard + Gamification)
```

## 📖 Documentation

- [Setup Guide](docs/01_SETUP.md)
- [Architecture](docs/02_ARCHITECTURE.md)
- [Admin Guide](docs/03_ADMIN_GUIDE.md)
- [Player Guide](docs/04_PLAYER_GUIDE.md)
- [Anonymous User Guide](docs/05_ANONYMOUS_USER.md)
- [MITRE ATT&CK Map](docs/MITRE_ATTACK_MAP.md)

## 🎮 Gamification

The web portal includes light gamification:
- 🏴 **Flag submission** — Submit user + root flags per machine
- ⚡ **Points** — Easy: 10, Medium: 25, Hard: 50, Insane: 100
- 📊 **Progress heatmap** — Visual grid of your conquests
- 🩸 **First blood badges** — First player to root a machine
- 👤 **Player profiles** — Track owned machines and total progress

## 🛠️ Admin CLI

```bash
./run.sh up                           # Start the lab
./run.sh up --enable-escape-challenges # Start with Docker escape challenges (VM only!)
./run.sh down                         # Stop everything
./run.sh reset 01                     # Reset machine 01
./run.sh reset all                    # Reset all machines
./run.sh status                       # Machine status overview
./run.sh health 01                    # Health check machine 01
./run.sh logs 01                      # View machine 01 logs
./run.sh vpn-add player4              # Add VPN peer
```

## 📜 License

MIT License — See [LICENSE](LICENSE)

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## For More Specific Information

See [docs/](docs/)
