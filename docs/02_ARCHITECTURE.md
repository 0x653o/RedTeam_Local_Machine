# 🏗️ Architecture

## Network Topology

```
                    ┌──────────────────────────────────┐
                    │         HOST MACHINE             │
                    │                                  │
  Player VPN ──────▶│  ┌──────────┐  ┌──────────────┐  │
  (WireGuard)       │  │ VPN GW   │  │  Web Portal  │  │
                    │  │ 10.10.0.2│  │  10.10.0.3   │  │
                    │  └────┬─────┘  └──────────────┘  │
                    │       │    infra_net 10.10.0.0/24 │
                    │       │                          │
                    │  ┌────┴────────────────────────┐ │
                    │  │      Docker Bridge Router    │ │
                    │  └────┬───┬───┬───┬───┬───┬──┘  │
                    │       │   │   │   │   │   │      │
                    │   ┌───┘ ┌─┘ ┌─┘ ┌─┘ ┌─┘ ┌─┘     │
                    │   ▼     ▼   ▼   ▼   ▼   ▼       │
                    │  m01  m02 m03 ... m41  m42       │
                    │ .1.0  .2.0 .3.0    .41.0 .42.0  │
                    │  /24   /24  /24     /24   /24    │
                    └──────────────────────────────────┘
```

## Isolation Model

### Network Isolation
- Each machine has its own Docker bridge network
- Subnet: `10.10.{N}.0/24` where N is the machine ID
- Machine IP: `10.10.{N}.10`
- No cross-machine communication possible

### Process Isolation
- Each container has its own PID namespace
- `--pid=host` is NEVER used
- `pids_limit` set to prevent fork bombs

### Storage Isolation
- No shared volumes between machines
- Each machine has ephemeral storage
- Flags are generated at startup from environment variables

### Capability Restrictions
- Minimal `cap_add` by default
- Only kernel exploit machines (36-38) get `SYS_PTRACE`
- `no-new-privileges` disabled only where SUID exploitation is needed

## Component Architecture

### Infrastructure Services (10.10.0.0/24)
- `10.10.0.2` — WireGuard VPN Gateway
- `10.10.0.3` — Web Portal (Dashboard + Gamification)

### Challenge Machines (10.10.{1-42}.0/24)
Each isolated in its own network segment.

### Lifecycle Manager
Background daemon monitoring health and enforcing resets.

## Security Boundaries

```
┌─────────────────────────────────────────────┐
│              HOST SYSTEM                     │
│                                              │
│  ┌─────────────────────────────────────────┐ │
│  │           DOCKER DAEMON                  │ │
│  │                                          │ │
│  │  ┌──────────┐   ┌──────────────────────┐│ │
│  │  │ Infra    │   │  Challenge Machines   ││ │
│  │  │ Services │   │  (per-machine PID/   ││ │
│  │  │          │   │   NET/MNT namespace) ││ │
│  │  └──────────┘   └──────────────────────┘│ │
│  └─────────────────────────────────────────┘ │
│                                              │
│  Escape challenges breach this boundary ──── │
│  (gated behind --enable-escape-challenges)   │
└─────────────────────────────────────────────┘
```
