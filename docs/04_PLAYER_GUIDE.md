# 🎮 Player Guide

## Getting Started

### 1. Connect via VPN

Your admin will provide a WireGuard configuration file.

```bash
# Install WireGuard
sudo apt-get install wireguard

# Import config
sudo cp player.conf /etc/wireguard/lm.conf

# Connect
sudo wg-quick up lm

# Verify
ping 10.10.0.3  # Should reach the portal
```

### 2. Access the Dashboard

Open your browser and navigate to:
```
https://10.10.0.3:8443
```

Login with:
- **Player ID**: Your chosen handle
- **Lab Secret**: Provided by your admin

### 3. Pick a Machine

Machines are organized by category and difficulty:

| Difficulty | Points | Recommended For |
|------------|--------|----------------|
| 🟢 Easy | 10 pts | Beginners, warmup |
| 🟡 Medium | 25 pts | Intermediate |
| 🔴 Hard | 50 pts | Advanced |
| 💀 Insane | 100 pts | Expert only |

**Start with Easy machines** to learn the lab workflow.

## Methodology

Every machine follows a 4-step kill chain:

### Step 1: Reconnaissance (GATE 0)
```bash
nmap -sC -sV -p- 10.10.{N}.10
```
- Identify open ports
- Determine service versions
- OS fingerprinting

### Step 2: Enumeration (GATE 1)
- Research identified services for known CVEs
- Confirm vulnerability version
- Map the attack surface
- Tools: `nikto`, `gobuster`, `wpscan`, etc.

### Step 3: Exploitation (GATE 2)
- Exploit the initial vulnerability
- Get a shell or access
- Find and capture the **user flag** (`/home/user/user.txt`)

### Step 4: Post-Exploitation (GATE 3)
- Enumerate privilege escalation vectors
- SUID binaries, cron jobs, sudo misconfigs, kernel vulns
- Escalate to root
- Capture the **root flag** (`/root/root.txt`)

## Flag Format

```
FLAG{32_character_hex_string}
```

Example: `FLAG{a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6}`

## Submitting Flags

### Via Dashboard
1. Navigate to the Dashboard
2. Select the machine from the dropdown
3. Paste the flag
4. Click Submit

### Points System

| Flag Type | Points |
|-----------|--------|
| User flag | 40% of machine points |
| Root flag | 60% of machine points |

### Ranks

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

## Tips

1. **Read the machine README** — Each machine has hints
2. **Take notes** — Document every step for learning
3. **Try before looking at writeups** — The struggle is the learning
4. **Use the right tools** — `nmap`, `burpsuite`, `metasploit`, `linpeas`
5. **Google the CVE** — Real advisories have exploitation details
6. **Check SUID binaries** — `find / -perm -u=s -type f 2>/dev/null`
7. **Machines reset every 60 minutes** — Save your progress!

## Machine IPs

All machines follow the pattern: `10.10.{MACHINE_ID}.10`

| ID Range | Category | IP Range |
|----------|----------|----------|
| 01–07 | Web Server & Runtime | 10.10.1.10 – 10.10.7.10 |
| 08–14 | CMS & Web Application | 10.10.8.10 – 10.10.14.10 |
| 15–22 | Framework & Library | 10.10.15.10 – 10.10.22.10 |
| 23–28 | Enterprise Middleware | 10.10.23.10 – 10.10.28.10 |
| 29–32 | Network Appliance & Proxy | 10.10.29.10 – 10.10.32.10 |
| 33–35 | Data & File Transfer | 10.10.33.10 – 10.10.35.10 |
| 36–38 | Privilege Escalation | 10.10.36.10 – 10.10.38.10 |
| 39–42 | Advanced Exploitation | 10.10.39.10 – 10.10.42.10 |
