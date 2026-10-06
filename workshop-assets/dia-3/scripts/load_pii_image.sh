#!/usr/bin/env bash
# =============================================================================
# workshop-assets/dia-3/scripts/load_pii_image.sh — deja disponible kong/ai-pii:local
# (perfil "pii", demo de ai-sanitizer del Módulo IA 03). Sólo instructor.
#   1. Si ya existe, no hace nada.
#   2. Si hay un backup .tar (AI_PII_TAR), lo carga.
#   3. Si no, la descarga del registro privado de Kong con las credenciales que Kong
#      entrega al cliente: AI_PII_REGISTRY_USER / AI_PII_REGISTRY_TOKEN (kong-env).
# Adaptado de scripts/load-pii-image.sh del Demo Track AI Gateway 2.
# =============================================================================
source "$(dirname "${BASH_SOURCE[0]}")/../../dia-4/scripts/common.sh"
IMG="${AI_PII_IMAGE:-docker.cloudsmith.io/kong/ai-pii/service:v0.1.4-en}"
docker image inspect kong/ai-pii:local >/dev/null 2>&1 && { pass "kong/ai-pii:local disponible"; exit 0; }
if [[ -n "${AI_PII_TAR:-}" && -f "${AI_PII_TAR}" ]]; then
  mostrar_cmd "docker load -i \$AI_PII_TAR"
  docker load -i "$AI_PII_TAR" >/dev/null || die "no se pudo cargar ${AI_PII_TAR}"
elif [[ -n "${AI_PII_REGISTRY_USER:-}" && -n "${AI_PII_REGISTRY_TOKEN:-}" ]]; then
  echo "$AI_PII_REGISTRY_TOKEN" | docker login docker.cloudsmith.io -u "$AI_PII_REGISTRY_USER" --password-stdin >/dev/null || die "login al registro privado falló"
  docker pull --platform linux/amd64 "$IMG" >/dev/null || die "no se pudo descargar ${IMG}"
  docker tag "$IMG" kong/ai-pii:local
else
  fail "sin AI_PII_TAR ni credenciales AI_PII_REGISTRY_USER / AI_PII_REGISTRY_TOKEN: se omite la demo de PII"; exit 1
fi
pass "kong/ai-pii:local disponible"
