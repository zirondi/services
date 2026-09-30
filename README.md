# Services Documentation

## Deployment Map

| Service | Host |
| --- | --- |
| socket-proxy | ALL |
| traefik-public | Helsinki |
| traefik-cloudflared | Nitro5, RPi |
| portainer | Helsinki |
| whoami | Helsinki |
| calibre-web | Helsinki |
| n8n | Helsinki |
| copyparty | Helsinki |
| csp-watcher | Helsinki |
| diun | TBD |
| duplicati | TBD |
| heimdall | TBD |
| homeassistant | RPi |
| pihole | RPi |
| cloudflared | RPi |

## How to Deploy
Run the `deploy.sh` script to deploy these services.

## Conventions
- See `.template/README.md` for standard structure
- Secrets mapped to `/run/secrets/`
- Volumes mapped to `${HOME}/volumes/<service>/`

## Network Architecture
- `edge-network`: External network for Traefik routing
- `socket-proxy`: Network for Docker socket proxy API
- `tunnel`: Cloudflared tunnel network
