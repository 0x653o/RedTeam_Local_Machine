# 🎮 Player Guide

## Getting Started

### Step 1 — Register

Visit the portal URL your admin gave you:

```
https://<server-ip>:8443
```

Click **Register**, enter your username and email. Your account is created immediately.

---

### Step 2 — Download Your VPN File

1. Go to your **Profile** page (top-right)
2. Click **Download VPN**
3. Save the file: `yourname.ovpn`

This file is unique to you — it contains your personal certificate. **Do not share it.**

---

### Step 3 — Connect to VPN

```bash
# Linux / macOS
sudo openvpn yourname.ovpn

# Windows
# Install OpenVPN GUI → import yourname.ovpn → Connect

# Verify connection
ping <server-ip>   # should respond
```

Keep this terminal open. The VPN must stay connected while you hack.

---

### Step 4 — Spawn a Machine

1. Open the **Dashboard**
2. Browse machines by category and difficulty
3. Click a machine → click **Spawn**
4. Wait a few seconds — your machine's IP appears on the card

```
Log4Hell is running
IP: 10.42.0.31    ← this is your personal machine IP
```

> Every player gets a **separate, independent instance** of the machine. Your actions don't affect other players' machines.

---

### Step 5 — Start Hacking

```bash
# Recon — always start here
nmap -sC -sV -p- <your-machine-ip>
```

No restrictions. Run `nmap`, `hydra`, `sqlmap`, `metasploit`, `ffuf` — whatever you need.

---

### Step 6 — Submit Flags

Flags are inside the machine:
- User flag: `/home/user/user.txt`
- Root flag: `/root/root.txt`

Format: `FLAG{32_hex_characters}`

Submit via the dashboard:
1. Click the machine card
2. Paste your flag in the submission box
3. Click **Submit**

> Flags are unique per player — you cannot use someone else's flag.

---

### Refresh = Fix

If your machine crashes or becomes unreachable:
1. **Refresh the dashboard page**
2. The portal detects the issue and auto-respawns your machine
3. A new IP is shown — continue from there

No need to contact the admin for crashed machines.

---

## Switching Machines

Click a different machine on the dashboard → click **Spawn**.  
Your current machine is **automatically terminated** and a new one starts.  
You can only have one active machine at a time.

---

## Methodology

Every machine follows a 4-step kill chain. You **cannot skip steps** — each gate depends on completing the previous one.

### Step 1 — Reconnaissance (Gate 0)
```bash
nmap -sC -sV -p- <machine-ip>
```
Identify open ports, service versions, OS.

### Step 2 — Enumeration (Gate 1)
- Research identified services for known CVEs
- Confirm vulnerable version
- Map the attack surface
- Tools: `nikto`, `gobuster`, `wpscan`, `feroxbuster`

### Step 3 — Exploitation (Gate 2)
- Exploit the initial vulnerability
- Get shell / access
- Capture **user flag** at `/home/user/user.txt`

### Step 4 — Post-Exploitation (Gate 3)
- Enumerate privilege escalation vectors
- SUID binaries, cron jobs, sudo misconfigs, kernel vulns
- Escalate to root
- Capture **root flag** at `/root/root.txt`

---

## Points & Ranks

| Flag Type | Points |
|-----------|--------|
| User flag | 40% of machine value |
| Root flag | 60% of machine value |

| Difficulty | Machine Value |
|------------|--------------|
| 🟢 Easy | 10 pts |
| 🟡 Medium | 25 pts |
| 🔴 Hard | 50 pts |
| 💀 Insane | 100 pts |

| Points | Rank |
|--------|------|
| 0 | 👶 Script Kiddie |
| 1–49 | 🌱 Noob Hacker |
| 50–149 | 📡 Network Scout |
| 150–299 | 🔧 Bug Hunter |
| 300–499 | ⚡ Penetration Tester |
| 500–699 | 🔴 Red Teamer |
| 700–999 | 💀 Exploit Developer |
| 1000+ | 🏴 Elite Hacker |

---

## Tips

1. **Read the machine README** — Each machine has difficulty rating, CVE hint, and methodology hint
2. **Nmap everything** — Version detection (`-sV`) reveals the vulnerable service version
3. **Google the CVE** — The official advisory often links to a PoC
4. **`linpeas.sh` for privesc** — Uploads it to the machine after getting user shell
5. **Take notes** — You will want to reference your own steps later
6. **Try before writeups** — The struggle is the actual learning
7. **Machines reset every 60 minutes** — Note your progress before reset

---

## FAQ

**Q: My machine IP changed after a refresh — is that normal?**  
A: Yes. If the machine crashed and was respawned, it gets a new IP. Update your terminal.

**Q: Can I see other players' machines?**  
A: No. Network isolation (Kubernetes NetworkPolicy) ensures your VPN traffic only reaches your own machines.

**Q: Someone submitted my flag?**  
A: Not possible — flags are unique per player. `sha256(seed + your_user_id + machine_id)`.

**Q: Can I run scripts that generate a lot of traffic?**  
A: Yes. This platform is specifically designed to allow heavy scanning, brute-forcing, and exploit traffic. Go for it.

**Q: What happens to my progress when a machine resets?**  
A: Submitted flags are saved in the portal permanently. Only the machine container is reset — your points remain.
