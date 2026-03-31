# School Server Deployment — Option 1: Open Port Allowed

## Overview

This option works when your school allows at least one open UDP port on the server.

## Architecture

```
Internet ──▶ School Firewall ──▶ [UDP:51820] ──▶ WireGuard Container ──▶ Lab
```

## Setup

### 1. Request a Port

Ask your network admin to forward **one UDP port** (e.g., 51820) to your server's internal IP.

### 2. Configure WireGuard

```bash
# Edit .env
VPN_PORT=51820  # Or whatever port was approved
```

### 3. Generate Peer Configs

```bash
# For each student
./run.sh vpn-add student01
./run.sh vpn-add student02
# ... etc
```

### 4. Distribute Configs

Each student receives their WireGuard `.conf` file. They can connect from any location.

### 5. Firewall Rules

On the host server:
```bash
# Allow WireGuard UDP
sudo ufw allow 51820/udp

# Allow traffic from VPN subnet to Docker networks
sudo iptables -A FORWARD -s 10.10.254.0/24 -d 10.10.0.0/16 -j ACCEPT
sudo iptables -A FORWARD -s 10.10.0.0/16 -d 10.10.254.0/24 -m state --state ESTABLISHED,RELATED -j ACCEPT
```

## Security Considerations

- Only UDP/51820 is exposed — no web-facing attack surface
- WireGuard uses modern cryptography (Curve25519, ChaCha20, BLAKE2s)
- Each student has a unique key pair — revocation is simple
- VPN subnet is isolated from the host's production network
