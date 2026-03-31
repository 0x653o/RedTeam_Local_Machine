# Contributing to Local-Machine

Thank you for your interest in contributing! This document outlines how to add new machines, fix bugs, and improve the lab.

## Adding a New Machine

### 1. Create the Machine Directory

```bash
# Example: Adding machine 43 in category 01
mkdir -p machines/01_WebServer_Runtime/43-newmachine/{config,flags,writeup}
```

### 2. Required Files

Every machine MUST include:

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Machine definition with isolated network |
| `Dockerfile` | Build instructions for the vulnerable environment |
| `healthcheck.sh` | Health validation (port, vuln, flags) |
| `config/` | Service configs, vulnerable app code |
| `flags/generate.sh` | Flag generation script |
| `README.md` | Machine card (difficulty, CVE, hints) |
| `writeup/solution.md` | Full step-by-step walkthrough |
| `writeup/exploit.py` | Working automated exploit |
| `writeup/references.md` | CVE links, advisories, patches |

### 3. Machine Requirements

- [ ] Uses a **real CVE** with CVSS ≥ 7.0 (or notable CWE)
- [ ] Enforces the **kill chain** (RECON → ENUMERATE → EXPLOIT → POST-EXPLOIT)
- [ ] Has a **user flag** (`/home/user/user.txt`) and **root flag** (`/root/root.txt`)
- [ ] Runs in an **isolated Docker network** (`10.10.{N}.0/24`)
- [ ] Has a working **health check**
- [ ] Includes a **complete writeup** with exploit code
- [ ] Maps to at least one **MITRE ATT&CK technique**

### 4. Network Convention

```yaml
networks:
  machine_{NN}_net:
    driver: bridge
    ipam:
      config:
        - subnet: 10.10.{NN}.0/24
          gateway: 10.10.{NN}.1
```

### 5. Testing

```bash
# Build and start your machine
docker compose -f machines/XX_Category/NN-name/docker-compose.yml up -d

# Verify health check
docker exec lm-NN-name /healthcheck.sh

# Follow your own writeup to verify the kill chain
```

## Code Style

- Shell scripts: Use `shellcheck`-compliant bash
- Python: Follow PEP 8, use type hints
- Docker: Multi-stage builds where possible
- YAML: 2-space indentation

## Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Add your machine(s)
4. Ensure health checks pass
5. Submit a PR with a description of the CVE and kill chain

## Security

If you discover a security issue with the lab infrastructure itself (not the intentionally vulnerable machines), please report it privately.
