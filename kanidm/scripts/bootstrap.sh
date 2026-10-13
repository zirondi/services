#!/usr/bin/env bash
# -------------------------------------------------------------------
# bootstrap.sh — Setup Inicial do Kanidm (Grupos e OIDC)
# Rodar DENTRO do container: podman exec -it kanidm bash
# -------------------------------------------------------------------
set -euo pipefail

echo "=> Configurando grupos de domínios..."
kanidm group create leazirondi_family
kanidm group create cacco_members
kanidm group create seccomp_organizers

# --- Calibre-Web ---
echo "=> OIDC: Calibre-Web (calibre.leazirondi.com.br)"
kanidm system oauth2 create calibre_web "Calibre-Web" https://calibre.leazirondi.com.br
kanidm system oauth2 add-redirect-url calibre_web https://calibre.leazirondi.com.br/oauth/callback
kanidm system oauth2 update-scope-map calibre_web leazirondi_family openid email profile

# --- Trilium ---
echo "=> OIDC: Trilium Notes (notes.leazirondi.com.br)"
kanidm system oauth2 create trilium "Trilium Notes" https://notes.leazirondi.com.br
kanidm system oauth2 add-redirect-url trilium https://notes.leazirondi.com.br/api/oauth/callback
kanidm system oauth2 update-scope-map trilium leazirondi_family openid email profile

# --- Stalwart Mail ---
echo "=> OIDC: Stalwart Mail (mail-admin.leazirondi.com.br)"
kanidm system oauth2 create stalwart_mail "Stalwart Mail" https://mail-admin.leazirondi.com.br
kanidm system oauth2 add-redirect-url stalwart_mail https://mail-admin.leazirondi.com.br/api/oauth
kanidm system oauth2 update-scope-map stalwart_mail leazirondi_family openid email profile

# --- Traefik Dashboard ---
echo "=> OIDC: Traefik Dashboard (traefik.leazirondi.com.br)"
kanidm system oauth2 create traefik_dashboard "Traefik Dashboard" https://traefik.leazirondi.com.br
kanidm system oauth2 add-redirect-url traefik_dashboard https://traefik.leazirondi.com.br/_oauth
kanidm system oauth2 update-scope-map traefik_dashboard leazirondi_family openid email profile

# --- Exibir credenciais ---
echo "==================================================================="
echo "=> Credenciais OIDC geradas:"
for client in calibre_web trilium stalwart_mail traefik_dashboard; do
  echo "-------------------------------------------------------------------"
  echo "Client: $client"
  kanidm system oauth2 show-basic-secret "$client"
done
echo "==================================================================="
echo "✅ Pronto. Guarde as credenciais acima no Vaultwarden!"
