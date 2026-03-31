# 📋 Setup Guide

## Prerequisites

### Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 4 cores | 8+ cores |
| RAM | 16 GB | 32+ GB |
| Storage | 100 GB SSD | 250 GB SSD |
| Network | 100 Mbps | 1 Gbps |

### Software Requirements

```bash
# Docker Engine (20.10+)
curl -fsSL https://get.docker.com | sh

# Docker Compose V2
sudo apt-get install docker-compose-plugin

# Verify
docker --version        # >= 20.10
docker compose version  # >= 2.0

# Optional: Multi-architecture support
sudo apt-get install qemu-user-static binfmt-support
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

### OS Support

| OS | Status |
|----|--------|
| Ubuntu 22.04+ | ✅ Fully supported |
| Debian 12+ | ✅ Fully supported |
| CentOS 9 Stream | ✅ Supported |
| macOS (Docker Desktop) | ⚠️ Works but no escape challenges |
| Windows (WSL2) | ⚠️ Limited support |

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/Local-Machine.git
cd Local-Machine
```

### 2. Configure Environment

```bash
# Copy example environment
cp .env .env.local

# Edit configuration
nano .env.local
```

**Critical settings:**
```bash
# Generate a random flag seed
FLAG_SEED=$(openssl rand -hex 32)

# Set portal access secret
PORTAL_SECRET=$(openssl rand -hex 16)
```

### 3. Generate Flags

```bash
chmod +x scripts/*.sh
./scripts/generate-all-flags.sh
```

### 4. Start the Lab

```bash
chmod +x run.sh lifecycle-manager.sh
./run.sh up
```

### 5. Verify

```bash
# Check status
./run.sh status

# Run health checks
./scripts/validate-machines.sh
```

## First Run Checklist

- [ ] Docker Engine installed and running
- [ ] `.env` configured with unique `FLAG_SEED`
- [ ] Flags generated via `generate-all-flags.sh`
- [ ] Lab started with `./run.sh up`
- [ ] Portal accessible at `https://localhost:8443`
- [ ] At least one machine responding to health checks
- [ ] VPN configured (if remote access needed)

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Port conflict | Change ports in `.env` |
| Out of memory | Reduce concurrent machines, increase swap |
| Build fails | Check Docker disk space: `docker system df` |
| Health check fails | Check machine logs: `./run.sh logs <id>` |
| VPN not connecting | Verify UDP port forwarding, check firewall |

### Useful Commands

```bash
# View all containers
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Clean up dangling resources
docker system prune -f

# Rebuild a specific machine
docker compose -f machines/01_WebServer_Runtime/01-log4hell/docker-compose.yml build --no-cache

# View resource usage
docker stats --no-stream
```
