# Portal Backend (FastAPI)

This directory will contain the FastAPI backend for the Local-Machine platform.

## Planned Structure

```
backend/
├── main.py                 # FastAPI app entrypoint
├── requirements.txt
├── Dockerfile
├── routers/
│   ├── auth.py             # /api/auth/register, /api/auth/login, /api/auth/refresh
│   ├── machines.py         # /api/machines/, /api/machines/{id}/spawn, /status
│   ├── flags.py            # /api/flags/submit
│   ├── profile.py          # /api/profile/, /api/profile/ovpn
│   └── admin.py            # /api/admin/users, /api/admin/pods, /api/admin/flags
├── services/
│   ├── k8s_service.py      # kubernetes Python client — create/delete/watch Pods
│   ├── vpn_service.py      # shell exec add-peer.sh / revoke-peer.sh
│   ├── flag_service.py     # sha256(FLAG_SEED + USER_ID + MACHINE_ID) validation
│   └── health_service.py   # Pod health check + auto-respawn logic
├── models/
│   ├── user.py
│   ├── session.py
│   ├── machine.py
│   └── flag_submission.py
└── db/
    ├── database.py         # PostgreSQL async connection (SQLAlchemy)
    └── migrations/         # Alembic migrations
```

## Key API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/auth/register` | Create account → provision k8s namespace |
| POST | `/api/auth/login` | JWT token |
| GET | `/api/profile/ovpn` | Stream user's `.ovpn` file |
| GET | `/api/machines/` | List all 42 machines with difficulty/status |
| POST | `/api/machines/{id}/spawn` | Create Pod in user namespace, return IP |
| GET | `/api/machines/{id}/status` | Pod health + current IP (used for polling) |
| DELETE | `/api/machines/{id}` | Terminate user's active Pod |
| POST | `/api/flags/submit` | Validate flag, award points |
| GET | `/api/admin/pods` | All active Pods across all users |

## Namespace Lifecycle (on register)

```python
# k8s_service.py
async def provision_user_namespace(username: str, vpn_ip: str):
    # 1. Create namespace: user-{username}
    # 2. Apply networkpolicy.yaml (patch with user's VPN IP)
    # 3. Apply namespace-rbac.yaml
    # Store vpn_ip in users table for NetworkPolicy updates
```

## Pod Health Check (called on every dashboard page load)

```python
# health_service.py
async def ensure_pod_healthy(user_id: int, machine_id: str):
    pod = await k8s.get_pod(namespace=f"user-{username}", label=f"machine={machine_id}")
    if pod is None:
        await k8s.spawn_pod(...)   # auto-respawn
    elif pod.status.phase in ("Failed", "CrashLoopBackOff"):
        await k8s.delete_pod(...)
        await k8s.spawn_pod(...)   # auto-respawn
    return pod.status.pod_ip       # return current IP
```

## Status: 🔲 TODO
