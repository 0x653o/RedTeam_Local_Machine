# 👋 Welcome to Local-Machine

## What is this?

Local-Machine is a **penetration testing practice lab**. It contains 42 vulnerable machines that you can legally hack to learn cybersecurity skills.

Think of it as a controlled shooting range for hackers — everything here is intentionally vulnerable, and you have permission to attack it.

## Who is this for?

- 🎓 Students learning cybersecurity
- 🔍 People preparing for certifications (OSCP, CEH, etc.)
- 💼 Professionals wanting to practice new techniques
- 🤓 Anyone curious about how hacking actually works

## What do I need?

1. **A computer** with at least 16 GB RAM
2. **Linux** (Ubuntu recommended) or Windows with WSL2
3. **Docker** installed
4. **Basic computer skills** — you should be comfortable with a terminal

## How do I start?

### If you're running locally:
```bash
git clone https://github.com/your-org/Local-Machine.git
cd Local-Machine
./run.sh up
```

### If someone gave you VPN access:
1. Install WireGuard: `sudo apt install wireguard`
2. Import the config file they gave you
3. Connect: `sudo wg-quick up lm`
4. Open the dashboard: `https://10.10.0.3:8443`

## What do I do?

1. **Pick a machine** — Start with Easy ones (03-PathFinder, 05-ShellShocked, 06-PHPocalypse)
2. **Scan it** — Use `nmap` to find open ports
3. **Research** — Look up the service version and known vulnerabilities
4. **Exploit** — Use the vulnerability to get a shell
5. **Find the flag** — Look for `FLAG{...}` in `/home/user/user.txt` and `/root/root.txt`
6. **Submit** — Enter the flag on the dashboard

## Is this legal?

**Yes!** This lab runs entirely on your own machine (or your school's server with permission). All machines are isolated Docker containers. You are not attacking any real systems.

## I'm stuck!

Each machine has:
- **Hints** in its README (check `machines/*/XX-name/README.md`)
- **A full writeup** (check `machines/*/XX-name/writeup/solution.md`)
- **Working exploit code** (in the writeup directory)

Start with the hints before reading the full solution. The struggle is part of learning!

## Glossary

| Term | Meaning |
|------|---------|
| **CVE** | Common Vulnerabilities and Exposures — a database of known security bugs |
| **RCE** | Remote Code Execution — running commands on a remote machine |
| **Priv Esc** | Privilege Escalation — going from normal user to admin/root |
| **SUID** | Set User ID — a special file permission in Linux |
| **Flag** | A secret string that proves you completed a challenge |
| **Reverse Shell** | A connection from the target machine back to you |
| **nmap** | A tool for scanning network ports |
