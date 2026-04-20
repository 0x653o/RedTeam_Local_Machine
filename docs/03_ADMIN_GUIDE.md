# 🔧 Admin Guide

## Initial Server Setup (Do Once)

### 1. Install k3s

```bash
curl -sfL https://get.k3s.io | sh -
# Verify
kubectl get nodes
```

### 2. Install Kata Containers (for escape challenge machines)

```bash
# Install Kata + Firecracker backend
bash -c "$(curl -fsSL https://raw.githubusercontent.com/kata-containers/kata-containers/main/utils/kata-manager.sh) install-kata-tools"

# Check hardware virtualization support first
grep -c "vmx\|svm" /proc/cpuinfo   # must be > 0

# Register RuntimeClass in k3s
kubectl apply -f - <<EOF
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: kata-fc
handler: kata-fc
EOF
```

> **Note**: If your server/VPS does not support nested virtualization (`/proc/cpuinfo` returns 0), escape challenges cannot use Kata. Keep `ENABLE_ESCAPE_CHALLENGES=false` in that case.

### 3. Initialize OpenVPN CA (one-time)

```bash
./infra/vpn/setup-ca.sh
# Reads SERVER_IP and VPN_PORT from .env
# Starts OpenVPN container, initializes PKI
```

### 4. Start the Portal

```bash
cd infra/portal && docker compose up -d
```

---

## Day-to-Day Operations

### Lab Start / Stop

```bash
./run.sh up      # Start VPN + portal
./run.sh down    # Stop everything (Pods stay — they're managed by k3s)
```

### Machine / Pod Management

```bash
# View all active Pods across all users
kubectl get pods -A -l managed-by=local-machine

# Kill a specific user's active Pod (forces respawn on next page load)
kubectl delete pod -n user-alice -l machine=log4hell

# Kill all of a user's Pods
kubectl delete pod -n user-alice --all

# View logs for a user's machine
kubectl logs -n user-alice -l machine=log4hell

# Force reset — delete Pod + user refreshes → portal auto-respawns
kubectl delete pod -n user-alice --all
```

### Health Check

```bash
# Check all Pods health
kubectl get pods -A -l managed-by=local-machine

# Check a single user
kubectl describe pod -n user-alice -l machine=log4hell
```

---

## VPN Management

```bash
# Add a player (generates alice.ovpn in infra/vpn/players/)
./scripts/add-peer.sh alice

# List all peers
docker exec lm-vpn-gw ovpn_listclients

# Revoke a player (immediate — cert added to CRL)
./scripts/revoke-peer.sh alice
```

Send the generated `.ovpn` file to the player. They connect with:
```bash
sudo openvpn alice.ovpn
```

---

## User Namespace Management

```bash
# List all user namespaces
kubectl get namespaces | grep user-

# Delete a user's namespace (removes all their Pods + NetworkPolicy)
kubectl delete namespace user-alice

# Provision namespace manually (normally done by portal on registration)
kubectl create namespace user-bob
kubectl apply -f infra/k8s/templates/networkpolicy.yaml -n user-bob
```

---

## Escape Challenge Management

Escape challenges (machines 09-PressGrave, 21-WebLogicBmb, 38-DirtyPipe) use the `kata-fc` RuntimeClass. They are **disabled by default** and must be explicitly enabled per-machine in the portal admin panel.

```bash
# Verify Kata runtime is working
kubectl run kata-test \
  --image=busybox \
  --overrides='{"spec":{"runtimeClassName":"kata-fc"}}' \
  --rm -it -- sh

# Inside the shell — verify you're in a VM, not the host
uname -r    # Should show Kata guest kernel version
ls /proc/1  # PID namespace is scoped to the VM
exit
```

When enabled:
- Pod runs under Firecracker microVM
- Player escapes to the Kata guest kernel, not the k3s host
- k3s node is fully protected regardless of what the player does inside

---

## Portal Administration

Access the admin panel at `https://<your-server-ip>:8443/admin`

From the admin panel you can:
- Create / suspend / delete user accounts
- View all active Pods per user with live status
- Kill or respawn any Pod
- View full flag submission history
- Enable / disable escape challenges per-machine
- Manage VPN peers (revoke, regenerate)

### Database (PostgreSQL)

```bash
# Connect to portal DB
docker exec -it lm-portal-db psql -U portal -d localmachine

# Key tables
SELECT * FROM users;
SELECT * FROM sessions;
SELECT * FROM flag_submissions ORDER BY created_at DESC LIMIT 20;
SELECT * FROM active_pods;
```

### Reset All Player Progress

```bash
# Via psql
docker exec -it lm-portal-db psql -U portal -d localmachine \
  -c "TRUNCATE flag_submissions, active_pods, sessions;"
```

---

## Lifecycle Manager

The lifecycle manager (Kubernetes CronJob) runs every 60 minutes and:
1. **Resets** all Pods that have been running > `MAX_INSTANCE_LIFETIME_MINUTES`
2. **Detects** CrashLoopBackOff Pods and triggers respawn
3. **Cleans up** orphaned namespaces for deleted users

```bash
# View lifecycle manager logs
kubectl logs -n kube-system -l app=lm-lifecycle-manager

# Manual trigger
kubectl create job --from=cronjob/lm-lifecycle-manager manual-reset -n kube-system
```

Configuration in `.env`:

| Variable | Default | Description |
|----------|---------|-------------|
| `MAX_INSTANCE_LIFETIME_MINUTES` | `60` | Max Pod uptime before reset |
| `HEALTH_CHECK_INTERVAL_SECONDS` | `30` | Portal health poll interval |
| `LOG_RETENTION_DAYS` | `7` | Log cleanup window |

---

## Resource Monitoring

```bash
# Node resource usage
kubectl top nodes

# Pod resource usage across all users
kubectl top pods -A -l managed-by=local-machine

# Per-user breakdown
kubectl top pods -n user-alice
```

Resource limits per machine Pod (set in each `k8s.yaml`):

| Resource | Default Limit |
|----------|--------------|
| Memory | 512 MB |
| CPU | 1.0 core |
| PIDs | 256 |
| Kata VM RAM (escape) | 512 MB (microVM overhead included) |

---

## Flag Management

```bash
# Change FLAG_SEED in .env, then regenerate
# (flags are computed dynamically — just change the seed, restart portal)
nano .env   # update FLAG_SEED=<new-random-string>
docker compose -f infra/portal/docker-compose.yml restart

# Verify new flags
curl -s http://localhost:8443/api/admin/verify-flags \
  -H "Authorization: Bearer <admin-token>"
```

Flags are unique **per user per machine** — changing `FLAG_SEED` invalidates all previously issued flags.
