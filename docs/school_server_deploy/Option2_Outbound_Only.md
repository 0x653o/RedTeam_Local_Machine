# School Server Deployment — Option 2: Outbound-Only

## Overview

This option works when your school blocks ALL inbound connections. It uses Tailscale or Cloudflare Tunnel for zero-trust access.

## Architecture

```
Students ──▶ Tailscale/CF Tunnel ──▶ (Outbound from server) ──▶ Lab
                                     No inbound ports needed!
```

## Option 2A: Tailscale

### Setup

```bash
# Install Tailscale on the server
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --advertise-routes=10.10.0.0/16

# Enable subnet routing in Tailscale admin console
# https://login.tailscale.com/admin/machines
```

### Student Access

1. Students install Tailscale on their machines
2. Admin invites students to the Tailscale network
3. Students can directly access machine IPs (10.10.X.10)

### Pros
- Zero configuration for firewalls
- End-to-end encrypted (WireGuard-based)
- Easy management via web dashboard

### Cons
- Requires Tailscale account (free tier: 100 devices)
- Students need to install Tailscale client

## Option 2B: Cloudflare Tunnel

### Setup

```bash
# Install cloudflared
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Login
cloudflared tunnel login

# Create tunnel
cloudflared tunnel create local-machine

# Configure
cat > ~/.cloudflared/config.yml << EOF
tunnel: <TUNNEL_ID>
credentials-file: /root/.cloudflared/<TUNNEL_ID>.json

ingress:
  - hostname: lab.yourschool.edu
    service: https://localhost:8443
  - service: http_status:404
EOF

# Run
cloudflared tunnel run local-machine
```

### Limitations

- Cloudflare Tunnel only proxies HTTP/HTTPS traffic
- Students cannot directly access machine IPs for nmap/exploitation
- This option is primarily useful for the **web portal** only
- For full lab access, use a socks proxy or VPN inside the tunnel

### Workaround: SOCKS Proxy

```bash
# On server, run a SOCKS proxy inside the tunnel
ssh -D 1080 -N tunnel-user@localhost

# Students configure their tools to use the SOCKS proxy
proxychains nmap 10.10.1.10
```

## Recommendation

**Tailscale (Option 2A)** is strongly recommended for outbound-only environments. It provides full network-level access with zero firewall changes.
