#!/usr/bin/env bash
# -------------------------------------------------------------------
# generate-certs.sh — Gera certificados TLS auto-assinados para o Kanidm
# Rodar no servidor ANTES de subir o container pela primeira vez.
# -------------------------------------------------------------------
set -euo pipefail

CERT_DIR="${HOME}/volumes/kanidm/data/certs"
mkdir -p "$CERT_DIR"

if [ -f "$CERT_DIR/chain.pem" ] && [ -f "$CERT_DIR/key.pem" ]; then
  echo "⚠️  Certificados já existem em $CERT_DIR. Use --force para regenerar."
  if [ "${1:-}" != "--force" ]; then
    exit 0
  fi
fi

openssl req -x509 -nodes -days 3650 \
  -subj "/CN=idm.leazirondi.com.br" \
  -addext "subjectAltName=DNS:idm.leazirondi.com.br" \
  -newkey rsa:4096 \
  -keyout "$CERT_DIR/key.pem" \
  -out "$CERT_DIR/chain.pem"

echo "✅ Certificados gerados em $CERT_DIR"
