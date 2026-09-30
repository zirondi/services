# Compose Services Conventions

Every stack must adhere to the following conventions:

- Every stack uses `name:` top-level key
- `restart: unless-stopped`
- `security_opt: [no-new-privileges=true]`
- Timezone mounts: `/etc/timezone:/etc/timezone:ro` and `/etc/localtime:/etc/localtime:ro`
- Secrets via file-based Docker secrets
- Volumes at `${HOME}/volumes/<service>/`
- Networks: `edge-network` for Traefik, `socket-proxy` for Docker API
- Traefik labels following the template in `traefik-label-template.yml`
