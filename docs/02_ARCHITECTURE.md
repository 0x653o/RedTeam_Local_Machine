# 🏗️ Architecture

## Overview

Local-Machine is a **Kubernetes-based multi-user red team training platform**. Each player gets a fully isolated environment. The platform is designed to safely host Docker escape challenges alongside regular CVE machines using different container runtimes.

---

## Network Topology

```
  Player Browser / Terminal
         │
         │  (1) Register + download .ovpn from portal
         │  (2) sudo openvpn username.ovpn
         ▼
  ┌──────────────────────────────────────────────────┐
  │           PUBLIC SERVER (dedicated IP)           │
  │                                                  │
  │  ┌──────────────────┐  ┌──────────────────────┐  │
  │  │   Web Portal     │  │  OpenVPN Gateway     │  │
  │  │  Next.js+FastAPI │  │  kylemanna/openvpn   │  │
  │  │  :8443 (HTTPS)   │  │  UDP :1194           │  │
  │  └──────────────────┘  └──────────┬───────────┘  │
  │                                   │              │
  │          ┌────────────────────────┘              │
  │          ▼                                       │
  │  ┌────────────────────────────────────────────┐  │
  │  │          Kubernetes Cluster (k3s)           │  │
  │  │                                            │  │
  │  │  ns:user-alice          ns:user-bob  ...   │  │
  │  │  ┌──────────────┐  ┌──────────────┐        │  │
  │  │  │ Pod:log4hell │  │ Pod:log4hell │        │  │
  │  │  │ 10.42.0.31   │  │ 10.42.0.47   │        │  │
  │  │  │ [runc]       │  │ [runc]       │        │  │
  │  │  └──────────────┘  └──────────────┘        │  │
  │  │                                            │  │
  │  │  ns:user-carol                             │  │
  │  │  ┌──────────────────────────────────────┐  │  │
  │  │  │ Pod:pressgrave (escape challenge)    │  │  │
  │  │  │ 10.42.0.58   [kata-fc / Firecracker] │  │  │
  │  │  └──────────────────────────────────────┘  │  │
  │  └────────────────────────────────────────────┘  │
  └──────────────────────────────────────────────────┘
```

---

## Isolation Model

### Layer 1 — Kubernetes Namespace Isolation

Every registered user gets a dedicated namespace at registration time:

```bash
kubectl create namespace user-alice
kubectl apply -f infra/k8s/templates/networkpolicy.yaml -n user-alice
```

- **Default-deny NetworkPolicy**: all ingress to the namespace is blocked by default
- Only the player's specific VPN IP is allowed to reach their Pods
- No cross-namespace Pod-to-Pod communication possible at the network layer

### Layer 2 — Dynamic Pod IP (no routing conflicts)

Machine Pods receive dynamic IPs from k3s's Pod CIDR (`10.42.0.0/16`). The portal backend reads the assigned IP post-spawn and stores it in PostgreSQL. No fixed-IP scheme — no routing table complexity.

```
alice spawns log4hell → Pod IP: 10.42.0.31  (shown on alice's dashboard)
bob  spawns log4hell → Pod IP: 10.42.0.47  (shown on bob's dashboard)
← same image, separate containers, different IPs, zero collision
```

### Layer 3 — securityContext (regular machines)

All regular machines (01–38, non-escape) enforce:

```yaml
securityContext:
  privileged: false
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
    add: []           # only add what the specific CVE requires
hostPID: false
hostNetwork: false
# no docker.sock mount
# no /dev mount
```

Root inside the container = root inside the container only. No host kernel access.

### Layer 4 — Kata Containers / Firecracker (escape challenge machines)

Docker escape challenge machines (09, 21, 38) are intentionally misconfigured — `privileged: true`, docker.sock mounted, etc. They are designed to be escaped. The question is: *escaped to where?*

With Kata Containers (Firecracker backend), escape lands in a **microVM guest kernel**, not the k3s host:

```
Player exploits docker.sock in Pod
  → escapes container
  → lands in Kata Firecracker guest Linux (~128MB RAM microVM)
  → [KVM hypervisor boundary]  ← cannot cross
  → k3s host is behind this boundary — fully protected
```

```yaml
# escape challenge Pod spec
spec:
  runtimeClassName: kata-fc    # ← Firecracker microVM runtime
  containers:
    - name: pressgrave
      securityContext:
        privileged: true       # intentional — Kata VM absorbs the escape
      volumeMounts:
        - name: docker-sock
          mountPath: /var/run/docker.sock
```

```yaml
# normal machine Pod spec
spec:
  # no runtimeClassName → uses default runc
  containers:
    - name: log4hell
      securityContext:
        privileged: false      # securityContext blocks escape
```

### Layer 5 — Ephemeral Storage

All Pods use `emptyDir` volumes only. When a Pod terminates (user switches machine, lifecycle reset, crash), all data is wiped. No cross-session or cross-user data leakage possible via storage.

### Layer 6 — Per-User Unique Flags

```
FLAG = sha256(FLAG_SEED + USER_ID + MACHINE_ID)
```

Alice's flag on Log4Hell ≠ Bob's flag on Log4Hell. A player cannot submit another player's flag.

---

## Security Boundaries Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    k3s HOST NODE                        │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │              Kubernetes (k3s)                    │   │
│  │                                                  │   │
│  │  ┌─────────────────┐  ┌──────────────────────┐   │   │
│  │  │  Regular Pods   │  │  Escape Challenge Pod │   │   │
│  │  │  (runc)         │  │  (kata-fc)            │   │   │
│  │  │                 │  │  ┌────────────────┐   │   │   │
│  │  │  securityContext│  │  │ Kata microVM   │   │   │   │
│  │  │  blocks escape  │  │  │ (Firecracker)  │   │   │   │
│  │  │                 │  │  │  ┌──────────┐  │   │   │   │
│  │  │                 │  │  │  │vulnerable│  │   │   │   │
│  │  │                 │  │  │  │container │  │   │   │   │
│  │  │                 │  │  │  └──────────┘  │   │   │   │
│  │  │                 │  │  └────────────────┘   │   │   │
│  │  └─────────────────┘  └──────────────────────┘   │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
│  Escape challenge: player breaks out of vulnerable      │
│  container → lands in Kata microVM → KVM boundary stops │
│  them → k3s host is never reachable                     │
└─────────────────────────────────────────────────────────┘
```

---

## Component Summary

| Component | Technology | Notes |
|-----------|------------|-------|
| Orchestrator | k3s | Lightweight Kubernetes, single-binary |
| Container runtime (normal) | runc (default) | Standard OCI runtime |
| Container runtime (escape) | Kata Containers + Firecracker | Hardware VM isolation |
| VPN | OpenVPN (kylemanna/openvpn) | Per-user PKI cert, `.ovpn` file |
| Portal frontend | Next.js (App Router) | Registration, dashboard, Spawn |
| Portal backend | FastAPI (Python) | k8s API calls, flag validation |
| Database | PostgreSQL | Users, sessions, Pod IPs, flags |
| Lifecycle Manager | k8s CronJob | Auto-reset (60 min), crash recovery |
