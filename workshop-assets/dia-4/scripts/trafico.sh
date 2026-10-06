#!/usr/bin/env bash
# =============================================================================
# workshop-assets/dia-4/scripts/trafico.sh [segundos=120] — tráfico mixto entre
# modelos y consumers para poblar Konnect Analytics, OpenObserve y Phoenix (Lab IA 08).
# Sólo usa los modelos que existan (los labs aplicados); los 404/403/429 también
# son datos útiles para las métricas RED.
# =============================================================================
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
aigw_load_env
require_cmd curl jq
DUR=${1:-120}; END=$(( $(date +%s) + DUR ))
PROMPTS=("¿Qué es una transferencia inmediata? Responde en una frase."
         "Escribe una función Python que valide un IBAN. Sólo el código."
         "Resume en una frase qué es el lavado de dinero."
         "¿Cuál es el límite por operación entre las 22:00 y las 06:00 en el Banco Demo?"
         "¿Cuánto cuesta la tarjeta Platinum del Banco Demo?")
MODELOS=(chat chat chat-cuotas auto asistente chat-cache codigo chat-seguro)
KEYS=("$AIGW_KEY_EQUIPO_DATOS" "$AIGW_KEY_APP_WEB" "$AIGW_KEY_AGENTE_COPILOT")
header "Tráfico mixto durante ${DUR}s contra ${PROXY_URL}"
n=0
while (( $(date +%s) < END )); do
  m=${MODELOS[$((RANDOM % ${#MODELOS[@]}))]}; p=${PROMPTS[$((RANDOM % ${#PROMPTS[@]}))]}; k=${KEYS[$((RANDOM % ${#KEYS[@]}))]}
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 180 -X POST "${PROXY_URL}/v1/chat/completions" \
    -H "apikey: $k" -H 'Content-Type: application/json' \
    -d "$(jq -cn --arg m "$m" --arg p "$p" '{model:$m,messages:[{role:"user",content:$p}]}')" || true)
  n=$((n+1)); printf "  #%-4s %-12s HTTP %s\n" "$n" "$m" "$code"
done
pass "${n} requests enviados — Konnect Analytics / OpenObserve (service_name = ${AIGW_OTEL_SERVICE_NAME}) / Phoenix"
