# 🔧 Admin Guide

## Day-to-Day Operations

### Starting and Stopping

```bash
# Start entire lab
./run.sh up

# Stop entire lab
./run.sh down

# Start with escape challenges (VM ONLY)
./run.sh up --enable-escape-challenges
```

### Machine Management

```bash
# View all machine statuses
./run.sh status

# Reset a specific machine
./run.sh reset 01

# Reset all machines
./run.sh reset all

# View machine logs
./run.sh logs 01

# Run health check
./run.sh health 01
./run.sh health    # All machines
```

### VPN Management

```bash
# Add a new VPN peer
./run.sh vpn-add player4

# List VPN peers
./run.sh vpn-list
```

The VPN configs are generated in `infra/vpn/config/peer_{name}/`.
Distribute the `.conf` file or QR code to players.

### Flag Management

```bash
# Regenerate all flags (change FLAG_SEED in .env first)
./scripts/generate-all-flags.sh

# Flags are deterministic: same seed = same flags
# Change the seed for each new session/class
```

## Lifecycle Manager

The lifecycle manager runs as a background daemon and handles:

1. **Auto-recovery**: Dead/exited containers are automatically restarted
2. **Health-based restart**: Unhealthy containers (3 consecutive failures) are restarted
3. **Scheduled reset**: Containers running > 60 minutes are reset to clean state

### Configuration

| Setting | Env Variable | Default |
|---------|-------------|---------|
| Max lifetime | `MAX_INSTANCE_LIFETIME_MINUTES` | 60 |
| Check interval | `HEALTH_CHECK_INTERVAL_SECONDS` | 30 |
| Log retention | `LOG_RETENTION_DAYS` | 7 |
| Log directory | `LOG_DIR` | `/var/log/local-machine` |

### Viewing Logs

```bash
tail -f /var/log/local-machine/lifecycle.log
```

## Resource Management

### Monitoring

```bash
# Overall Docker resource usage
docker stats --no-stream

# Per-machine breakdown
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

### Resource Limits (per machine)

| Resource | Limit |
|----------|-------|
| Memory | 512 MB |
| CPU | 1.0 core |
| PIDs | 256 |

### Scaling Down

If resources are limited, run machines in batches:
```bash
# Start only category 1
for f in machines/01_WebServer_Runtime/*/docker-compose.yml; do
    docker compose -f "$f" up -d
done
```

## Portal Administration

### Player Data
Player progress is stored in `infra/portal/data/players.json`.

### Reset Player Progress
```bash
rm infra/portal/data/players.json
rm infra/portal/data/first_bloods.json
```

### Change Portal Secret
Update `PORTAL_SECRET` in `.env` and restart the portal:
```bash
docker compose -f infra/portal/docker-compose.yml restart
```
