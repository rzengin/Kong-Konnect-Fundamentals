#!/usr/bin/env bash
# =============================================================================
# workshop-assets/dia-4/scripts/setup_lab.sh — Lab IA 00 (idempotente)
#
#   1. Prerrequisitos (docker, kongctl >= 1.20.1, jq, curl, openssl, python3)
#   2. Tu AI Gateway en Konnect: "<DEMO_PREFIX>-ai-gw" (o AI_GATEWAY_ID exportado)
#   3. Secretos locales (API keys de los consumers) en $AIGW_STATE_DIR (fuera del repo)
#   4. Certificado del Data Plane (generado aquí y registrado en tu AI Gateway)
#   5. Contenedores: DP 2.2 + Redis Stack + WireMock (+ Ollama)
#   6. Modelos open-weight en Ollama (CPU): llama3.2:1b, qwen3:0.6b, nomic-embed-text
#   7. Base de conocimiento RAG (Lab IA 05)
#   8. Configuración base con kongctl (gateway externo, proveedor Ollama, identidad)
#
# Variables obligatorias:  KONNECT_TOKEN  DEMO_PREFIX
# Opcionales:  KONNECT_ADDR (default https://us.api.konghq.com)  AI_GATEWAY_ID
#              AIGW_OLLAMA_MODE=host (usar Ollama instalado en el host)
#              AIGW_MODELO_GENERAL / AIGW_MODELO_CODIGO (otros modelos de Ollama)
#              SKIP_KONGCTL=1 (no aplicar la config base)
# =============================================================================
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
AUTO_MODE=true

header "Día 4 · Lab IA 00 — Setup del AI Gateway 2.2 (Konnect + Data Plane local)"

step "1/8 Prerrequisitos"
require_cmd docker kongctl jq curl openssl python3
docker info >/dev/null 2>&1 || die "Docker no está corriendo"
kongctl_version_ok || die "kongctl $(kongctl version 2>/dev/null | head -1) es anterior a ${KONGCTL_MIN_VERSION}: no conoce las entidades de AI Gateway 2.1/2.2. Actualízalo (Lab IA 00, paso 1)."
require_env KONNECT_TOKEN DEMO_PREFIX
aigw_load_env
pass "herramientas OK · kongctl $(kongctl version 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -1) · Konnect ${KONNECT_API}"

step "2/8 Tu AI Gateway en Konnect"
if [[ -z "${AI_GATEWAY_ID:-}" ]]; then
  mostrar_cmd "curl -s -H 'Authorization: Bearer \$KONNECT_TOKEN' ${KONNECT_API}/v1/ai-gateways"
  AI_GATEWAY_ID=$(konnect GET "/v1/ai-gateways" 2>/dev/null \
    | jq -r --arg n "$AIGW_GATEWAY_NAME" '(.data // .items // [])[] | select(.name==$n or .display_name==$n) | .id' | head -1)
  [[ -n "$AI_GATEWAY_ID" ]] || die "No encontré el AI Gateway '${AIGW_GATEWAY_NAME}'. Créalo en Konnect (AI Gateway > New AI Gateway, versión 2.2) o exporta AI_GATEWAY_ID."
fi
GW_JSON=$(konnect GET "/v1/ai-gateways/${AI_GATEWAY_ID}") || die "AI Gateway ${AI_GATEWAY_ID} no accesible con tu KONNECT_TOKEN (¿región? KONNECT_ADDR=${KONNECT_ADDR})"
save_generated AI_GATEWAY_ID "$AI_GATEWAY_ID"
save_generated AIGW_STATE_DIR "$AIGW_STATE_DIR"
save_generated DEMO_PREFIX "$DEMO_PREFIX"
pass "AI Gateway '$(jq -r '.display_name // .name' <<<"$GW_JSON")' (${AI_GATEWAY_ID})"
info "versión declarada en Konnect: $(jq -r '.version // .gateway_version // "ver en la UI"' <<<"$GW_JSON") · imagen del DP: ${KONG_DP_IMAGE} (deben coincidir EXACTAMENTE)"

step "3/8 Secretos locales en ${AIGW_STATE_DIR} (fuera del repositorio)"
mkdir -p "${AIGW_STATE_DIR}/certs"; chmod 700 "${AIGW_STATE_DIR}"
for c in APP_WEB EQUIPO_DATOS AGENTE_COPILOT AGENTE_CONSULTA APP_CREDITO; do
  v="AIGW_KEY_${c}"
  [[ -n "${!v:-}" ]] || save_generated "$v" "lab-$(echo "$c" | tr '[:upper:]_' '[:lower:]-')-$(openssl rand -hex 6)"
done
pass "API keys de los consumers en ${AIGW_GEN_ENV} (permisos 600)"

step "4/8 Certificado del Data Plane"
if [[ ! -s "${AIGW_STATE_DIR}/certs/tls.crt" ]]; then
  openssl req -new -x509 -nodes -newkey rsa:2048 -days 365 -subj "/CN=aigw-lab-${DEMO_PREFIX}" \
    -keyout "${AIGW_STATE_DIR}/certs/tls.key" -out "${AIGW_STATE_DIR}/certs/tls.crt" 2>/dev/null
  chmod 644 "${AIGW_STATE_DIR}/certs/tls.key"   # el usuario kong del contenedor debe poder leerla
  mostrar_cmd "POST ${KONNECT_API}/v1/ai-gateways/\$AI_GATEWAY_ID/data-plane-certificates"
  aigw POST /data-plane-certificates -d "$(jq -n --rawfile c "${AIGW_STATE_DIR}/certs/tls.crt" \
    --arg t "aigw-lab-${DEMO_PREFIX}" '{cert: $c, title: $t}')" >/dev/null || die "no se pudo registrar el certificado del DP"
  pass "certificado generado y registrado en tu AI Gateway"
else
  info "ya existe ${AIGW_STATE_DIR}/certs/tls.crt (para rotarlo: teardown.sh --all y volver a ejecutar setup)"
fi
save_generated KONNECT_CLUSTER_HOST "$(jq -r '.endpoints.configuration' <<<"$GW_JSON" | sed 's#^https://##')"
save_generated KONNECT_TELEMETRY_HOST "$(jq -r '.endpoints.telemetry' <<<"$GW_JSON" | sed 's#^https://##')"
pass "endpoints del CP: ${KONNECT_CLUSTER_HOST} / ${KONNECT_TELEMETRY_HOST}"

step "5/8 Contenedores locales (DP ${KONG_DP_IMAGE} + Redis + WireMock$( [[ "$AIGW_OLLAMA_MODE" == container ]] && echo " + Ollama"))"
docker network inspect kong-workshop >/dev/null 2>&1 || docker network create kong-workshop >/dev/null
PROFILES=()
[[ "$AIGW_OLLAMA_MODE" == "container" ]] && PROFILES+=(--profile ollama)
if [[ "${WITH_DEMO_EXTRAS:-0}" == "1" ]]; then   # sólo instructor (Día 3)
  PROFILES+=(--profile compresion)
  if docker image inspect kong/ai-pii:local >/dev/null 2>&1; then PROFILES+=(--profile pii)
  else warn "sin imagen kong/ai-pii:local (workshop-assets/dia-3/scripts/load_pii_image.sh): se omite el AI PII service"; fi
  [[ "$AIGW_HEADROOM_TOKEN" != "sin-configurar" ]] || save_generated AIGW_HEADROOM_TOKEN "hr_$(openssl rand -hex 12)"
fi
mostrar_cmd "docker compose -f workshop-assets/dia-4/docker-compose.yml ${PROFILES[*]:-} up -d"
dc ${PROFILES[@]+"${PROFILES[@]}"} up -d --remove-orphans || die "docker compose up falló"
wait_for "Data Plane healthy" 180 bash -c "[[ \$(docker inspect -f '{{.State.Health.Status}}' aigw-lab-dp) == healthy ]]"
wait_for "Data Plane conectado a tu AI Gateway" 180 bash -c \
  "curl -sf -H 'Authorization: Bearer ${KONNECT_TOKEN}' '${KONNECT_API}/v1/ai-gateways/${AI_GATEWAY_ID}/nodes' | jq -e '(.data // .items // []) | length > 0'"

step "6/8 Modelos open-weight en Ollama (CPU) — puede tardar varios minutos la primera vez"
if [[ "$AIGW_OLLAMA_MODE" == "host" ]]; then
  command -v ollama >/dev/null 2>&1 || die "AIGW_OLLAMA_MODE=host pero no está el comando 'ollama' en el host"
fi
for m in "$AIGW_MODELO_GENERAL" "$AIGW_MODELO_CODIGO" "$AIGW_MODELO_EMBED"; do
  mostrar_cmd "ollama pull $m"
  ollama_cmd pull "$m" >/dev/null && pass "modelo ${m} disponible" || die "no se pudo descargar ${m}"
done

step "7/8 Base de conocimiento RAG (Redis + embeddings nomic-embed-text)"
bash "${AIGW_ROOT}/scripts/load_rag.sh" || warn "no se pudo cargar la base RAG (reintenta con scripts/load_rag.sh antes del Lab IA 05)"

step "8/8 Configuración base con kongctl (proveedor Ollama + identidad)"
if [[ "${SKIP_KONGCTL:-0}" == "1" ]]; then
  skip "SKIP_KONGCTL=1"
else
  mostrar_cmd "workshop-assets/dia-4/scripts/aplicar.sh 00"
  bash "${AIGW_ROOT}/scripts/aplicar.sh" 00 || die "kongctl falló (ejecuta 'aplicar.sh 00 --diff' para ver el detalle)"
fi
CHECK_TIMEOUT=120 check_retry "DP con configuración recibida (/status/ready)" 200 "http://localhost:${AIGW_STATUS_PORT:-8110}/status/ready"

echo -e "
${BOLD}Listo.${NC}
  Proxy AI Gateway .. ${PROXY_URL}   (POST /v1/chat/completions, header apikey)
  Konnect ........... https://cloud.konghq.com/${KONNECT_REGION}/ai-manager/v2/gateways/${AI_GATEWAY_ID}
  Modelos ........... ${AIGW_MODELO_GENERAL} · ${AIGW_MODELO_CODIGO} · ${AIGW_MODELO_EMBED} (Ollama ${AIGW_OLLAMA_MODE})
  API keys .......... source ${AIGW_GEN_ENV}   (variables AIGW_KEY_*)
  Siguiente ......... Lab IA 01: workshop-assets/dia-4/scripts/aplicar.sh 01"
resumen
