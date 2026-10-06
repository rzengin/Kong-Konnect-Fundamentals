#!/usr/bin/env bash
# =============================================================================
# workshop-assets/dia-3/scripts/metering_billing.sh — Demo opcional del Módulo IA 08
# Metering & Billing: tokens por consumer -> meter -> feature -> plan -> customer -> factura
#
# OPCIONAL (instructor): requiere el add-on Konnect Metering & Billing y la policy
# global aplicada con:  WITH_METERING=1 workshop-assets/dia-4/scripts/aplicar.sh 08
# Variables (perfil kong-env del instructor): KONNECT_TOKEN (admin de Metering &
# Billing) y METERING_INGEST_TOKEN (System Account token con rol Ingest).
# Adaptado de scenarios/12-metering-billing/demo.sh del Demo Track AI Gateway 2.
# Los endpoints /v3/openmeter/* y sus campos pueden variar según la versión de la
# API: si un paso falla, mostrar el resultado en la UI de Konnect.
# =============================================================================
source "$(dirname "${BASH_SOURCE[0]}")/../../dia-4/scripts/common.sh"
aigw_load_env
require_cmd jq curl
require_env KONNECT_TOKEN METERING_INGEST_TOKEN AI_GATEWAY_ID AIGW_KEY_APP_WEB AIGW_KEY_EQUIPO_DATOS

OM=/v3/openmeter
METER_KEY=aigw_curso_tokens; FEATURE_KEY=aigw_curso_tokens; PLAN_KEY=aigw_curso_plan_ia
items() { jq -c '(.items // .data // [])[]'; }
om_find() { konnect GET "${OM}/$1?page_size=100" 2>/dev/null | items | jq -r --arg k "$2" 'select(.key==$k) | .id' | head -1 || true; }
consumer_id() { aigw GET /consumers | jq -r --arg n "$1" '(.data // .items // [])[] | select(.name==$n) | .id' | head -1; }

header "Módulo IA 08 · Metering & Billing: cobrar la IA como un producto"

step "1. Policy metering-and-billing activa en el AI Gateway"
if aigw GET /policies | jq -e '(.data // .items // [])[] | select(.name=="metering-y-billing")' >/dev/null 2>&1; then
  pass "policy global 'metering-y-billing' (meter_ai_token_usage, subject = consumer)"
else
  fail "no existe la policy 'metering-y-billing': WITH_METERING=1 workshop-assets/dia-4/scripts/aplicar.sh 08"; resumen; exit 1
fi
pausa

step "2. Catálogo de billing (idempotente): meter -> feature -> plan"
METER_ID=$(om_find meters "$METER_KEY")
if [[ -z "$METER_ID" ]]; then
  METER_ID=$(konnect POST "${OM}/meters" -d "$(jq -n --arg k "$METER_KEY" '{
      name: "Tokens de IA (curso AI Gateway)", key: $k,
      description: "Tokens de entrada y salida por modelo/proveedor",
      event_type: "kong.llm_request", aggregation: "sum", value_property: "$.tokens",
      dimensions: {model: "$.model", provider: "$.provider", type: "$.type"}}')" | jq -r .id) \
    || die "no se pudo crear el meter (¿add-on Metering & Billing habilitado?)"
fi
pass "meter ${METER_KEY} (${METER_ID})"
FEATURE_ID=$(om_find features "$FEATURE_KEY")
if [[ -z "$FEATURE_ID" ]]; then
  FEATURE_ID=$(konnect POST "${OM}/features" -d "$(jq -n --arg k "$FEATURE_KEY" --arg m "$METER_ID" '{
      name: "Tokens de IA", key: $k, meter: {id: $m}}')" | jq -r .id) || die "no se pudo crear la feature"
fi
pass "feature ${FEATURE_KEY} (${FEATURE_ID})"
PLAN_ID=$(om_find plans "$PLAN_KEY")
if [[ -z "$PLAN_ID" ]]; then
  # Precio ILUSTRATIVO: USD 0,002 por 1.000 tokens
  PLAN_ID=$(konnect POST "${OM}/plans" -d "$(jq -n --arg k "$PLAN_KEY" --arg f "$FEATURE_ID" --arg fk "$FEATURE_KEY" '{
      name: "Plan IA por consumo (curso)", key: $k, currency: "USD", billing_cadence: "P1M",
      phases: [{name: "Principal", key: "principal", rate_cards: [{
        name: "Tokens de IA", key: $fk, billing_cadence: "P1M", feature: {id: $f},
        price: {type: "unit", amount: "0.000002"}, entitlement: {type: "boolean"}}]}]}')" | jq -r .id) \
    || die "no se pudo crear el plan"
  konnect POST "${OM}/plans/${PLAN_ID}/publish" >/dev/null || warn "no se pudo publicar el plan (¿ya publicado?)"
fi
pass "plan ${PLAN_KEY} (${PLAN_ID})"
pausa

step "3. Customers de billing = AI Consumers del gateway (subject consumer:<id>) + suscripción"
for c in app-web equipo-datos; do
  cid=$(consumer_id "$c"); [[ -n "$cid" ]] || { fail "consumer ${c} no encontrado"; continue; }
  ckey="curso-${c}"
  if [[ -z "$(om_find customers "$ckey")" ]]; then
    konnect POST "${OM}/customers" -d "$(jq -n --arg k "$ckey" --arg n "Cliente ${c}" --arg s "consumer:${cid}" \
      '{name: $n, key: $k, usage_attribution: {subject_keys: [$s]}}')" >/dev/null || { fail "no se pudo crear ${ckey}"; continue; }
    konnect POST "${OM}/subscriptions" -d "$(jq -n --arg k "$ckey" --arg p "$PLAN_KEY" \
      '{customer: {key: $k}, plan: {key: $p}}')" >/dev/null || warn "no se pudo suscribir ${ckey}"
  fi
  pass "${ckey} <- consumer:${cid}"
done
pausa

step "4. Tráfico: cada request emite eventos de tokens por consumer"
for c in APP_WEB EQUIPO_DATOS; do
  k="AIGW_KEY_${c}"
  llm "${!k}" chat "Resume en 2 oraciones qué es el interés compuesto."
  printf "    %-14s HTTP %s  %s\n" "$c" "$LLM_STATUS" "$(llm_usage)"
done
pausa

step "5. Uso medido (la ingesta es asíncrona: hasta 1 minuto)"
sleep "${METERING_WAIT:-20}"
if q=$(konnect GET "${OM}/meters/${METER_ID}/query?group_by=subject" 2>/dev/null); then
  jq -r '(.data // .items // [])[] | "    \(.subject // .group_by.subject // "-")\t\(.value) tokens"' <<<"$q" | head -10 || true
else
  warn "la consulta del meter por API no respondió: verlo en la UI"
fi
info "Konnect -> Metering & Billing -> Billing -> Invoices (factura en borrador por customer)"
resumen
