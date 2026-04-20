# 🏴 LOCAL-MACHINE — PROJECT STATUS & CONTEXT

> **Last Updated**: 2026-04-21
> **Purpose**: Full context document so work can resume from any new conversation.
> **Key Reference**: `implementation_plan.md` is the master blueprint.

---

## 1. PROJECT OVERVIEW

A **self-hosted HackTheBox-style red team training platform**. Players register on a web portal, download a personal `.ovpn` file, connect once via OpenVPN, and get access to 42 isolated challenge machines. Each machine is built around a real Critical/High CVE with a strict MITRE ATT&CK kill chain.

**Core Design Principles**:
- Multi-user server platform (not a local-only tool)
- Per-user Kubernetes namespace isolation — one active Pod per user at a time
- Dynamic Pod IPs — portal reads live IP post-spawn, refresh auto-respawns crashed machines
- OpenVPN per-user PKI certs (HTB-style `.ovpn` file)
- Kata Containers (Firecracker) for Docker escape challenge machines — escape lands in microVM, not host
- Unique flags per user per machine: `sha256(FLAG_SEED + USER_ID + MACHINE_ID)`
- Auto-recovery via lifecycle manager (60-min resets via k8s CronJob)

---

## 2. ARCHITECTURE DECISIONS (FINAL)

| Decision | Resolution | Where |
|----------|------------|-------|
| Orchestration | **Kubernetes (k3s)** — per-user namespace, 1 Pod/user | §3 impl_plan |
| VPN | **OpenVPN** (kylemanna/openvpn) — self-contained `.ovpn` file | §8.1 |
| Machine IP model | **Dynamic Pod IP** — k8s assigns, portal displays live | §3.2 |
| Escape challenge safety | **Kata Containers (Firecracker)** — microVM wraps escape machines | §7.2 |
| Portal stack | Next.js (frontend) + FastAPI (backend) + PostgreSQL | §8.3 |
| Flag uniqueness | Per-user per-machine hash (prevents flag sharing) | §8.4 |
| Multi-arch machines | Separate `k8s.arm64.yaml` / `k8s.mips.yaml` per machine | §7.1 |
| Escape challenge gating | Admin enables per-machine via portal `/admin` panel | §7.2 |
| Portal recovery | Refresh page → portal detects crash → auto-respawns Pod | §3.3 |

---

## 3. INFRASTRUCTURE STATUS

### 3.1 Core Infrastructure Files

| File | Status | Notes |
|------|--------|-------|
| `.env.example` | ✅ Updated | Scenario-aware: Local/Homelab/School-OpenPort/School-Outbound |
| `run.sh` | ✅ Exists | Admin CLI — needs k8s command updates |
| `lifecycle-manager.sh` | ✅ Exists | Needs migration from Docker to k8s CronJob |
| `README.md` | ✅ Updated | Reflects server platform + k8s + Kata |
| `implementation_plan.md` | ✅ Updated | Full architecture rewrite (§3, §7, §8, §9, §10) |
| `PROJECT_STATUS.md` | ✅ Updated | This file |

### 3.2 VPN (`infra/vpn/`)

| File | Status | Notes |
|------|--------|-------|
| `docker-compose.yml` | ✅ Updated | kylemanna/openvpn (was WireGuard) |
| `setup-ca.sh` | ✅ Exists | One-time PKI init, reads SERVER_IP from .env |
| `players/` | ✅ Created | Generated `.ovpn` files go here (gitignored) |
| `data/` | ✅ Created | PKI certs (gitignored) |

### 3.3 Kubernetes (`infra/k8s/`)

| File | Status | Notes |
|------|--------|-------|
| `templates/networkpolicy.yaml` | ✅ Created | Default-deny + VPN IP allowlist per namespace |
| `templates/namespace-rbac.yaml` | ✅ Created | Portal backend ClusterRole + user read-only Role |
| `cluster-setup.sh` | 🔲 TODO | k3s install + Kata Containers + RuntimeClass setup |

### 3.4 Portal (`infra/portal/`)

| File/Dir | Status | Notes |
|----------|--------|-------|
| `docker-compose.yml` | ✅ Exists | Needs update for Next.js + FastAPI split |
| `frontend/` | 🔲 TODO | Next.js App Router — registration, dashboard, Spawn |
| `backend/` | 🔲 TODO | FastAPI — k8s API calls, flag validation, VPN mgmt |
| `k8s/` | 🔲 TODO | Portal Deployment + Service manifests |
| `src/` (legacy) | ⚠️ Stale | Old Express.js portal — replaced by frontend/backend |

### 3.5 Scripts (`scripts/`)

| File | Status | Notes |
|------|--------|-------|
| `add-peer.sh` | ✅ Exists | Generates `.ovpn` via kylemanna/openvpn |
| `revoke-peer.sh` | ✅ Exists | CRL-based cert revocation |
| `generate-all-flags.sh` | ✅ Exists | Batch flag generation |
| `validate-machines.sh` | ✅ Exists | Health check validation |
| `generate-machines.py` | ✅ Exists | Used to scaffold machines 04-42 |
| `reset-machine.sh` | ✅ Exists | Single machine reset (Docker-era, needs k8s update) |
| `reset-all.sh` | ✅ Exists | Reset all (Docker-era, needs k8s update) |

### 3.6 Documentation (`docs/`)

| File | Status | Notes |
|------|--------|-------|
| `01_SETUP.md` | ⚠️ Stale | Needs k3s + Kata Containers + OpenVPN CA + portal setup |
| `02_ARCHITECTURE.md` | ✅ Updated | k8s topology, 6-layer isolation, Kata security model |
| `03_ADMIN_GUIDE.md` | ✅ Updated | kubectl ops, Kata setup, VPN peer management |
| `04_PLAYER_GUIDE.md` | ✅ Updated | Register → OVPN → Spawn → hack → refresh-to-fix |
| `05_ANONYMOUS_USER.md` | ⚠️ Stale | References WireGuard — needs OpenVPN update |
| `MITRE_ATTACK_MAP.md` | ✅ Exists | Full ATT&CK coverage matrix |
| `school_server_deploy/Option1_VPN_Allowed.md` | ✅ Exists | Open port deployment |
| `school_server_deploy/Option2_Outbound_Only.md` | ✅ Exists | Tailscale + Cloudflare Tunnel |

---

## 4. DEPLOYMENT ENVIRONMENT GUIDE (QUICK REF)

See `implementation_plan.md §3.6` for full detail.

| Scenario | SERVER_IP | VPN | Portal | Extra |
|----------|-----------|-----|--------|-------|
| **A — Local dev** | `127.0.0.1` | `ENABLE_VPN=false` | `localhost:8443` | Direct Pod IP access |
| **B — Homelab/VPS** | your public IP | OpenVPN UDP 1194 | `<ip>:8443` | Open UDP 1194 + TCP 8443 |
| **C — School (open port)** | campus public IP | OpenVPN UDP `<approved>` | `<ip>:8443` | iptables VPN→k8s route needed |
| **D — School (outbound-only)** | Tailscale IP `100.x` | Tailscale + OpenVPN | Cloudflare Tunnel URL | Students install Tailscale |

---

## 5. MACHINE IMPLEMENTATION STATUS

### 5.1 Status Legend

- 🟢 **DEEP**: Fully implemented. Custom vulnerable app, specific Dockerfile, working exploit.
- 🟡 **SCAFFOLDED**: All standard files exist but Dockerfile is generic. Needs `config/setup.sh`, `config/start-service.sh`, and updated Dockerfile.
- 🔲 **k8s manifest**: Each machine also needs `k8s.yaml` (Pod + Service spec) — none created yet.

### 5.2 Per-Machine Status

| # | Name | CVE | Docker Status | k8s.yaml | Kata Runtime |
|---|------|-----|--------------|----------|--------------|
| 01 | Log4Hell | CVE-2021-44228 | 🟢 DEEP | 🔲 TODO | runc |
| 02 | SpringBreak | CVE-2022-22965 | 🟢 DEEP | 🔲 TODO | runc |
| 03 | PathFinder | CVE-2021-41773 | 🟢 DEEP | 🔲 TODO | runc |
| 04 | StrutsZone | CVE-2017-5638 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 05 | ShellShocked | CVE-2014-6271 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 06 | PHPocalypse | CVE-2012-1823 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 07 | GhostCat | CVE-2020-1938 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 08 | DrupalDoom | CVE-2018-7600 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 09 | PressGrave | CVE-2022-0739 | 🟡 SCAFFOLDED | 🔲 TODO | **kata-fc** |
| 10 | BulletProof | CVE-2019-16759 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 11 | Confluencer | CVE-2022-26134 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 12 | GitLabyrinth | CVE-2021-22205 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 13 | GrafanLeak | CVE-2021-43798 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 14 | JoomBleed | CVE-2023-23752 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 15 | Ignition | CVE-2021-3129 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 16 | ThinkPwned | CVE-2018-20062 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 17 | ImageTragick | CVE-2016-3714 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 18 | ProtoPoison | CWE-1321 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 19 | PickleRick | CWE-502 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 20 | JWTwisted | CVE-2022-21449 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 21 | WebLogicBmb | CVE-2019-2725 | 🟡 SCAFFOLDED | 🔲 TODO | **kata-fc** |
| 22 | React2Shell | CVE-2025-55182 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 23 | JenkinsOwned | CVE-2024-23897 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 24 | ActiveMQtter | CVE-2023-46604 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 25 | RedisRaider | Miscfg | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 26 | MongoMayhem | Miscfg+NoSQLi | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 27 | ElasticPwn | CVE-2015-1427 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 28 | SolrBlaze | CVE-2019-17558 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 29 | BigIPwned | CVE-2022-1388 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 30 | CitrixBreaker | CVE-2019-19781 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 31 | IvantiGate | CVE-2024-21887 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 32 | MinIOLeaker | CVE-2023-28432 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 33 | MOVEitMstr | CVE-2023-34362 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 34 | ApacheNght | CVE-2023-25690 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 35 | GoAnywher | CVE-2023-0669 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 36 | BaronSamedit | CVE-2021-3156 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 37 | PwnKit | CVE-2021-4034 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 38 | DirtyPipe | CVE-2022-0847 | 🟡 SCAFFOLDED | 🔲 TODO | **kata-fc** |
| 39 | V8_MapRem | CVE-2018-17463 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 40 | V8_TurboConf | CVE-2020-6418 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 41 | V8_OOBArray | CVE-2021-30632 | 🟡 SCAFFOLDED | 🔲 TODO | runc |
| 42 | JSC_JITRCE | CVE-2020-9802 | 🟡 SCAFFOLDED | 🔲 TODO | runc |

> **Escape machines** (09, 21, 38) use `runtimeClassName: kata-fc` in their `k8s.yaml`.

---

## 6. WHAT EACH MACHINE NEEDS (k8s ERA)

Each machine needs these files to be complete:

```
machines/XX_Category/NN-machinename/
├── Dockerfile              ← already exists (generic for scaffolded)
├── k8s.yaml                ← NEW: Pod + Service spec for k3s
│                             (escape machines: runtimeClassName: kata-fc)
├── healthcheck.sh          ← already exists
├── config/
│   ├── entrypoint.sh       ← already exists
│   ├── setup.sh            ← MISSING on scaffolded (privesc setup)
│   └── start-service.sh    ← MISSING on scaffolded (vulnerable service start)
├── README.md               ← already exists
└── writeup/
    ├── solution.md         ← exists (skeleton, needs real steps)
    ├── exploit.py          ← exists (skeleton, needs real exploit)
    └── references.md       ← already exists
```

**k8s.yaml template (normal machine):**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: lm-{user}-{machine}
  labels:
    managed-by: local-machine
    machine: {machine-name}
    user: {username}
spec:
  restartPolicy: Never
  containers:
    - name: {machine-name}
      image: local-machine/{machine-name}:latest
      securityContext:
        privileged: false
        allowPrivilegeEscalation: false
        capabilities:
          drop: ["ALL"]
      resources:
        limits:
          memory: "512Mi"
          cpu: "1"
      env:
        - name: FLAG_SEED
          valueFrom:
            secretKeyRef:
              name: lm-secrets
              key: flag-seed
        - name: USER_ID
          value: "{user-id}"
        - name: MACHINE_ID
          value: "{machine-id}"
```

**k8s.yaml additions for escape machines (09, 21, 38):**
```yaml
spec:
  runtimeClassName: kata-fc   # ← Firecracker microVM
  containers:
    - securityContext:
        privileged: true      # intentional — Kata VM absorbs escape
```

---

## 7. IMMEDIATE NEXT STEPS

In priority order:

1. **`infra/k8s/cluster-setup.sh`** — k3s install + Kata Containers + RuntimeClass registration
2. **`infra/portal/backend/`** — FastAPI app (k8s API integration, flag validation, VPN management)
3. **`infra/portal/frontend/`** — Next.js app (registration, dashboard, Spawn button, live IP display)
4. **`docs/01_SETUP.md`** — Full server setup guide (k3s + Kata + OpenVPN CA + portal)
5. **`docs/05_ANONYMOUS_USER.md`** — Update WireGuard → OpenVPN references
6. **Machine `k8s.yaml` files** — Create for all 42 machines (escape machines use kata-fc)
7. **Scaffolded machines (04-42)** — Add `config/setup.sh` + `config/start-service.sh` + update Dockerfile

### Build Order for Machines (unchanged from before)

**Tier 1** (simplest): 05-ShellShocked, 25-RedisRaider, 06-PHPocalypse, 13-GrafanLeak, 16-ThinkPwned, 32-MinIOLeaker
**Tier 2** (medium): 04-StrutsZone, 07-GhostCat, 08-DrupalDoom, 10-BulletProof, 11-Confluencer, 14-JoomBleed, 15-Ignition, 17-ImageTragick, 24-ActiveMQtter, 27-ElasticPwn, 28-SolrBlaze, 37-PwnKit
**Tier 3** (complex custom app): 18-ProtoPoison, 19-PickleRick, 20-JWTwisted, 22-React2Shell, 26-MongoMayhem, 29-BigIPwned, 30-CitrixBreaker, 31-IvantiGate
**Tier 4** (large services / kernel): 09-PressGrave, 12-GitLabyrinth, 21-WebLogicBmb, 23-JenkinsOwned, 33-MOVEitMstr, 34-ApacheNght, 35-GoAnywher, 36-BaronSamedit, 38-DirtyPipe
**Tier 5** (browser engine): 39-42 (pre-built V8/JSC binaries needed)

---

## 8. KNOWN ISSUES

| # | Issue | Status |
|---|-------|--------|
| 1 | `infra/portal/src/` is legacy Express.js — replaced by frontend/backend split | ⚠️ Keep for now, migrate when portal is built |
| 2 | `run.sh` and `scripts/reset-*.sh` use Docker Compose commands — need k8s migration | 🔲 TODO |
| 3 | `lifecycle-manager.sh` is a bash daemon — needs migration to k8s CronJob | 🔲 TODO |
| 4 | `docs/01_SETUP.md` references old Docker-only setup | 🔲 TODO |
| 5 | `docs/05_ANONYMOUS_USER.md` references WireGuard | 🔲 TODO |
| 6 | Machine `docker-compose.escape.yml` files exist (09, 21, 38) — superseded by `kata-fc` runtimeClass | ⚠️ Keep for reference, note in README |
| 7 | `infra/shared/` directory exists but not in impl_plan structure | ⚠️ Keep (flag-generator.sh + healthcheck-base.sh still useful) |

---

## 9. FILE COUNTS

| Category | Count |
|----------|-------|
| Total files (approx) | ~500 |
| Machine Dockerfiles | 42 |
| Machine k8s.yaml | 0 (all TODO) |
| Escape docker-compose overrides | 3 (superseded by kata-fc) |
| Multi-arch k8s overrides | 0 (TODO) |
| Health checks | 42 |
| READMEs | 43 |
| Writeup solution.md | 42 |
| Exploit scripts | 42 |
| Infrastructure files | ~15 |
| Documentation files | 8 |
| K8s templates | 2 (networkpolicy, rbac) |
