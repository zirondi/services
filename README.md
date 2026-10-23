# 🚀 Production Services Orchestrator

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Runtime: Podman Compose](https://img.shields.io/badge/runtime-Podman_Compose-purple.svg)](https://podman.io)
[![Secrets: SOPS + Age](https://img.shields.io/badge/secrets-SOPS_%2B_Age-orange.svg)](.sops.yaml)

Declarative Podman Compose stacks for the servers managed by the [dotfiles](https://github.com/zirondi/dotfiles) flake, where this repository is the `services/` submodule. Most run on the Hetzner VPS in Helsinki (host `hetzner`). Image tags are pinned; `diun` reports new releases.

---

## 🗺️ Stacks

| Stack | Components | Exposure | State |
| :--- | :--- | :--- | :--- |
| **`socket-proxy`** | LinuxServer socket proxy | none | running |
| **`traefik`** | Traefik + two `cloudflared` connectors | ingress | running |
| **`whoami`** | Traefik test service | tailnet | running |
| **`n8n`** | n8n + PostgreSQL 16 | tunnel | running |
| **`vaultwarden`** | Vaultwarden | tunnel | running |
| **`mail`** | Stalwart (SMTP 25/465, IMAPS 993, Sieve 4190; admin over the tunnel) | public ports + tunnel | running |
| **`nextcloud`** | Nextcloud (Mail, Calendar, Contacts) + PostgreSQL 17 + Redis | tailnet | running |
| **`aliasvault`** | AliasVault (password and alias manager) + PostgreSQL | tunnel without `/admin`, tailnet with it | on trial |
| **`diun`** | Diun (image update notices to Telegram) | none | prepared |
| **`kanidm`** | Kanidm (identity) | — | parked (data kept on the host) |
| **`trilium`**, **`calibre-web`** | Trilium Notes, Calibre-Web Automated | — | never deployed; meant for the Oracle host |

---

## 🏛️ Networks

- **`cloudflared-network`**: Traefik and the Cloudflare Tunnel connectors. Nothing else joins it.
- **`tunnel-network`**: Traefik and the services published through the Cloudflare Tunnel or over the tailnet.
- **`public-network`**: Traefik and the services published directly on the host's public address.
- **`socket-proxy`**: the Docker API for Traefik and Diun.

Conventions for a new stack (exposure, hardening, secrets) are in `docs/agents/compose.md` of the dotfiles repository and in [`.template/`](.template).

---

## 🔐 Secrets (SOPS)

Secrets are age-encrypted for the admin key and the host keys listed in `.sops.yaml`; only `*.sops.yaml` files are committed. The deploy script decrypts them on the host with the host's SSH key.

```bash
sops services/<stack>/secrets/<name>.sops.yaml
```

---

## 🚢 Deployment

From the dotfiles repository, after validating:

```bash
just deploy hetzner --svc <stack> [<stack>...]
```
