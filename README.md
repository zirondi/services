# 🚀 Production Services Orchestrator

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Runtime: Podman Compose](https://img.shields.io/badge/runtime-Podman_Compose-purple.svg)](https://podman.io)
[![Secrets: SOPS + Age](https://img.shields.io/badge/secrets-SOPS_%2B_Age-orange.svg)](.sops.yaml)

Declarative Docker/Podman Compose application stacks deployed and running on cloud infrastructure (**Helsinki VPS**).

---

## 🗺️ Active Production Deployment (Helsinki)

| Stack | Service Components | Role / Network Placement |
| :--- | :--- | :--- |
| **`socket-proxy`** | LinuxServer Socket Proxy | Securely exposes the Docker/Podman daemon socket via TCP to Traefik without exposing the raw socket file. |
| **`traefik`** | Traefik + Cloudflared (Dual Tunnels) | Edge ingress reverse proxy routing personal (`*.leazirondi.com.br`) and academic (`*.unesp.br`) web traffic over Cloudflare Tunnels. |
| **`n8n`** | n8n + PostgreSQL 16 | Production self-hosted workflow automation platform with persistent relational storage. |

---

## 🏛️ Network Topology & Interconnects

- **`cloudflared-network`**: Connects Traefik to the Cloudflare Tunnel daemons. Nothing else joins it.
- **`tunnel-network`**: Traefik and the services published through the Cloudflare Tunnel or over the tailnet.
- **`public-network`**: Traefik and the services published directly on the host's public address.
- **`socket-proxy`**: Dedicated network allowing Traefik to query the Podman API for container label auto-discovery.

---

## 🔐 Secrets Management (SOPS)

All secrets are encrypted with **Age** keys matching the host SSH keys and admin keys configured in `.sops.yaml`:
```bash
# Encrypt or edit an existing secret:
sops services/<service>/secrets/<secret_name>.sops.yaml

# Runtime decryption on host:
sops -d secrets/<secret_name>.sops.yaml > secrets/<secret_name>
```

---

## 🚢 Deployment Workflow

Services are deployed declaratively from the dotfiles repository:
```bash
# Deploy all active production stacks to Helsinki:
./scripts/deploy.sh hetzner helsinki --svc socket-proxy traefik n8n
```
