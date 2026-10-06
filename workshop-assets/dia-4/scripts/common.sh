#!/usr/bin/env bash
# =============================================================================
# workshop-assets/dia-4/scripts/common.sh
# Helpers compartidos por los scripts del Día 4 (AI Gateway Labs), por
# run_all_labs_dia4.sh y por run_all_demos_dia3.sh.
#
# Uso:   source workshop-assets/dia-4/scripts/common.sh && aigw_load_env
#
# Origen: adaptado de lib/common.sh del Demo Track "Kong_Demo_AI_Gateway_2"
# (Perceptiva) al formato del curso (un AI Gateway por participante, modelos
# open-weight en Ollama, sin claves de pago).
#
# Secretos: NUNCA en este repositorio.
#   - KONNECT_TOKEN y DEMO_PREFIX: variables de entorno del participante
#     (los instructores las cargan con su perfil kong-env).
#   - API keys de los consumers, IDs y endpoints: $AIGW_STATE_DIR/.env.generated
#     (por defecto ~/.kong-workshop/aigw-lab, fuera del repo; lo crea setup_lab.sh).
# No usa `set -e`: se puede "sourcear" desde scripts interactivos.
# =============================================================================

AIGW_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"           # workshop-assets/dia-4
REPO_ROOT="$(cd "${AIGW_ROOT}/../.." && pwd)"                          # raíz del curso
AIGW_DIA3="${REPO_ROOT}/workshop-assets/dia-3"
export AIGW_ROOT REPO_ROOT AIGW_DIA3

# ---------- UI (mismo estilo que run_all_demos.sh / run_all_labs.sh) ---------
GREEN=${GREEN:-'\033[0;32m'}; RED=${RED:-'\033[0;31m'}; YELLOW=${YELLOW:-'\033[1;33m'}
CYAN=${CYAN:-'\033[1;36m'}; BOLD=${BOLD:-'\033[1m'}; DIM=${DIM:-'\033[2m'}; NC=${NC:-'\033[0m'}
PASSES=${PASSES:-0}; FAILURES=${FAILURES:-0}

declare -F header >/dev/null || header() {
  echo ""
  echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════${NC}"
  echo -e "${CYAN}${BOLD}  $1${NC}"
  echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════${NC}"
  echo ""
}
declare -F step >/dev/null        || step()        { echo -e "\n${YELLOW}${BOLD}  > $1${NC}\n"; }
declare -F mostrar_cmd >/dev/null || mostrar_cmd() { echo -e "\n  ${GREEN}\$ $1${NC}\n"; }
declare -F pass >/dev/null        || pass()        { echo -e "  ${GREEN}${BOLD}[OK] PASS${NC}: ${BOLD}$1${NC}"; PASSES=$((PASSES+1)); }
declare -F fail >/dev/null        || fail()        { echo -e "  ${RED}${BOLD}[FAIL] FAIL${NC}: ${BOLD}$1${NC}"; FAILURES=$((FAILURES+1)); }
declare -F skip >/dev/null        || skip()        { echo -e "  ${YELLOW}[SKIP]${NC} $1"; }
declare -F info >/dev/null        || info()        { echo -e "  ${DIM}$1${NC}"; }
declare -F warn >/dev/null        || warn()        { echo -e "  ${YELLOW}[!] $1${NC}"; }
declare -F die >/dev/null         || die()         { echo -e "${RED}${BOLD}ERROR:${NC} $1" >&2; exit 1; }
declare -F pausa >/dev/null       || pausa() {
  if [ "${AUTO_MODE:-true}" = false ] || [ "${INTERACTIVE:-0}" = 1 ]; then
    echo -ne "  ${CYAN}${BOLD}>> Presiona ENTER para continuar...${NC}"; read -r; echo ""
  fi
}
resumen() {
  echo ""
  if (( FAILURES == 0 )); then echo -e "${GREEN}${BOLD}  Resultado: ${PASSES} OK, 0 fallos${NC}"
  else echo -e "${RED}${BOLD}  Resultado: ${PASSES} OK, ${FAILURES} fallos${NC}"; fi
  return $(( FAILURES > 0 ? 1 : 0 ))
}

# ---------- entorno -----------------------------------------------------------
aigw_load_env() {
  : "${DEMO_PREFIX:=}"
  : "${AIGW_STATE_DIR:=${HOME}/.kong-workshop/aigw-lab}"
  AIGW_GEN_ENV="${AIGW_STATE_DIR}/.env.generated"
  # IDs, endpoints y API keys generados por setup_lab.sh (no pisan lo ya exportado)
  if [[ -f "$AIGW_GEN_ENV" ]]; then
    local line key val
    while IFS= read -r line || [[ -n "$line" ]]; do
      [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]] || continue
      key="${BASH_REMATCH[1]}"; val="${BASH_REMATCH[2]}"
      [[ -z "${!key:-}" ]] && export "$key=$val"
    done < "$AIGW_GEN_ENV"
  fi
  : "${KONNECT_ADDR:=https://us.api.konghq.com}"
  KONNECT_REGION="${KONNECT_ADDR#https://}"; KONNECT_REGION="${KONNECT_REGION%%.*}"
  export KONNECT_API="${KONNECT_ADDR}"
  : "${AIGW_GATEWAY_NAME:=${DEMO_PREFIX:-alumno}-ai-gw}"
  : "${KONG_DP_IMAGE:=kong/kong-ai-gateway:2.2.0}"
  : "${AIGW_PROXY_PORT:=8010}"
  export PROXY_URL="${PROXY_URL:-http://localhost:${AIGW_PROXY_PORT}}"
  # Modelos open-weight (CPU). Cambiarlos aquí o exportarlos antes del setup.
  : "${AIGW_MODELO_GENERAL:=llama3.2:1b}"
  : "${AIGW_MODELO_CODIGO:=qwen3:0.6b}"
  : "${AIGW_MODELO_EMBED:=nomic-embed-text}"          # 768 dimensiones (fijo en los YAML)
  # Ollama: container (default, perfil "ollama") | host (Ollama instalado en la máquina)
  : "${AIGW_OLLAMA_MODE:=container}"
  if [[ "$AIGW_OLLAMA_MODE" == "host" ]]; then : "${AIGW_OLLAMA_URL:=http://host.docker.internal:11434}"
  else : "${AIGW_OLLAMA_URL:=http://ollama:11434}"; fi
  export AIGW_OLLAMA_CHAT_URL="${AIGW_OLLAMA_URL}/api/chat"
  # OpenTelemetry (Lab IA 08): Collector del stack del curso, red kong-workshop
  : "${AIGW_OTEL_COLLECTOR_URL:=http://otel-collector:4318}"
  export AIGW_OTEL_TRACES_ENDPOINT="${AIGW_OTEL_TRACES_ENDPOINT:-${AIGW_OTEL_COLLECTOR_URL}/v1/traces}"
  export AIGW_OTEL_METRICS_ENDPOINT="${AIGW_OTEL_METRICS_ENDPOINT:-${AIGW_OTEL_COLLECTOR_URL}/v1/metrics}"
  export AIGW_OTEL_LOGS_ENDPOINT="${AIGW_OTEL_LOGS_ENDPOINT:-${AIGW_OTEL_COLLECTOR_URL}/v1/logs}"
  : "${AIGW_OTEL_SERVICE_NAME:=aigw-${DEMO_PREFIX:-alumno}}"
  # Escenarios opcionales del instructor (Día 3): claves comerciales, nunca en el repo
  export AIGW_OPENAI_AUTH_HEADER="Bearer ${OPENAI_API_KEY:-sin-configurar}"
  export AIGW_ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-sin-configurar}"
  export AIGW_GEMINI_API_KEY="${GEMINI_API_KEY:-sin-configurar}"
  : "${AIGW_HEADROOM_TOKEN:=sin-configurar}"
  : "${METERING_INGEST_ENDPOINT:=${KONNECT_API}/v3/openmeter/events}"
  export AIGW_METERING_INGEST_ENDPOINT="$METERING_INGEST_ENDPOINT"
  export AIGW_METERING_INGEST_TOKEN="${METERING_INGEST_TOKEN:-}"
  export DEMO_PREFIX AIGW_STATE_DIR AIGW_GEN_ENV KONNECT_ADDR KONNECT_REGION AIGW_GATEWAY_NAME \
         KONG_DP_IMAGE AIGW_PROXY_PORT AIGW_MODELO_GENERAL AIGW_MODELO_CODIGO AIGW_MODELO_EMBED \
         AIGW_OLLAMA_MODE AIGW_OLLAMA_URL AIGW_OTEL_COLLECTOR_URL AIGW_OTEL_SERVICE_NAME AIGW_HEADROOM_TOKEN
}

# Guarda/actualiza una variable en .env.generated (idempotente, permisos 600)
save_generated() {
  local key=$1 val=$2 tmp
  mkdir -p "$(dirname "$AIGW_GEN_ENV")"; touch "$AIGW_GEN_ENV"; chmod 600 "$AIGW_GEN_ENV"
  tmp=$(mktemp); grep -v "^${key}=" "$AIGW_GEN_ENV" > "$tmp" || true; mv "$tmp" "$AIGW_GEN_ENV"
  printf '%s=%s\n' "$key" "$val" >> "$AIGW_GEN_ENV"; chmod 600 "$AIGW_GEN_ENV"
  export "$key=$val"
}

require_cmd() { local c; for c in "$@"; do command -v "$c" >/dev/null 2>&1 || die "Falta el comando '$c' (ver Lab IA 00 > Prerrequisitos)"; done; }
require_env() {
  local v missing=0
  for v in "$@"; do [[ -n "${!v:-}" && "${!v}" != "kpat_XXXXXXXXX" ]] || { echo -e "${RED}  falta variable: $v${NC}" >&2; missing=1; }; done
  (( missing == 0 )) || die "Exporta las variables que faltan (KONNECT_TOKEN, DEMO_PREFIX) o activa tu perfil kong-env."
}

KONGCTL_MIN_VERSION=1.20.1
kongctl_version_ok() {
  local v; v=$(kongctl version 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  [[ -n "$v" ]] && [[ "$(printf '%s\n%s\n' "$KONGCTL_MIN_VERSION" "$v" | sort -V | head -1)" == "$KONGCTL_MIN_VERSION" ]]
}

# ---------- Konnect API -------------------------------------------------------
konnect() {  # konnect <METHOD> <path> [curl-args...]
  local method=$1 path=$2; shift 2
  curl -sS --fail-with-body -X "$method" "${KONNECT_API}${path}" \
    -H "Authorization: Bearer ${KONNECT_TOKEN}" -H "Content-Type: application/json" "$@"
}
aigw() { local method=$1 path=$2; shift 2; konnect "$method" "/v1/ai-gateways/${AI_GATEWAY_ID}${path}" "$@"; }

# ---------- Docker ------------------------------------------------------------
dc() {  # docker compose del Día 4 (+ override del Día 3 si WITH_DEMO_EXTRAS=1)
  local args=(--project-directory "$AIGW_ROOT" -f "${AIGW_ROOT}/docker-compose.yml")
  [[ "${WITH_DEMO_EXTRAS:-0}" == "1" && -f "${AIGW_DIA3}/docker-compose.demo.yml" ]] && args+=(-f "${AIGW_DIA3}/docker-compose.demo.yml")
  [[ -f "$AIGW_GEN_ENV" ]] && args+=(--env-file "$AIGW_GEN_ENV")
  docker compose "${args[@]}" "$@"
}
running() { [[ -n "$(docker ps -q -f "name=^$1$" -f status=running 2>/dev/null)" ]]; }
CURL_IMAGE="${CURL_IMAGE:-curlimages/curl:8.10.1}"
# svc_curl <url-interna> [args] — llama a un servicio de la red aigw-lab por su nombre
svc_curl() { docker run --rm -i --network aigw-lab --add-host host.docker.internal:host-gateway "$CURL_IMAGE" -s --max-time "${SVC_CURL_TIMEOUT:-120}" "$@"; }
redis_cli() { docker exec -i aigw-lab-redis redis-cli "$@"; }
ollama_cmd() {  # ollama_cmd <args...>  (container o host)
  if [[ "$AIGW_OLLAMA_MODE" == "host" ]]; then ollama "$@"; else docker exec aigw-lab-ollama ollama "$@"; fi
}

# ---------- kongctl: qué archivos se aplican en cada lab ----------------------
# Los labs son ACUMULATIVOS: el lab NN aplica base/ + lab_01 ... lab_NN.
# kongctl sync reconcilia por completo las colecciones del AI Gateway: lo que no
# esté en esos archivos se BORRA (por eso "aplicar.sh 00" deja el gateway limpio).
#   --solucion          usa soluciones/lab_NN_*.yaml en lugar de config/lab_NN_*.yaml
#   WITH_CLOUD=1        + proveedores y modelos comerciales (Día 3, claves del instructor)
#   WITH_DEMO_EXTRAS=1  + PII, compresión Headroom y custom policy (Día 3)
#   WITH_METERING=1     + policy metering-and-billing (add-on de Konnect)
KC_FILES=()
KC_TMP=""
kc_archivos() {
  local hasta=$((10#${1:-0})) modo=${2:-} i f sol
  KC_FILES=()
  KC_TMP=$(mktemp -d)
  [[ -n "${AI_GATEWAY_ID:-}" ]] || die "AI_GATEWAY_ID no definido: ejecuta workshop-assets/dia-4/scripts/setup_lab.sh"
  sed "s/__AI_GATEWAY_ID__/${AI_GATEWAY_ID}/" "${AIGW_ROOT}/config/base/00-gateway.yaml" > "${KC_TMP}/00-gateway.yaml"
  KC_FILES+=(-f "${KC_TMP}/00-gateway.yaml" -f "${AIGW_ROOT}/config/base/10-proveedores.yaml" -f "${AIGW_ROOT}/config/base/15-identidad.yaml")
  for (( i=1; i<=hasta; i++ )); do
    f=$(ls "${AIGW_ROOT}"/config/lab_$(printf '%02d' "$i")_*.yaml 2>/dev/null | head -1)
    [[ -n "$f" ]] || continue
    sol="${AIGW_ROOT}/soluciones/$(basename "$f")"
    if [[ "$modo" == "--solucion" && -f "$sol" ]]; then KC_FILES+=(-f "$sol"); else KC_FILES+=(-f "$f"); fi
  done
  if [[ "${WITH_CLOUD:-0}" == "1" ]]; then
    KC_FILES+=(-f "${AIGW_DIA3}/config/demo_05_secretos.yaml" -f "${AIGW_DIA3}/config/demo_10_proveedores_comerciales.yaml" \
               -f "${AIGW_DIA3}/config/demo_20_modelos_comerciales.yaml")
  fi
  if [[ "${WITH_DEMO_EXTRAS:-0}" == "1" ]]; then
    KC_FILES+=(-f "${AIGW_DIA3}/config/demo_30_pii.yaml" -f "${AIGW_DIA3}/config/demo_45_compresion.yaml" \
               -f "${AIGW_DIA3}/config/demo_80_custom_policy.yaml")
  fi
  if [[ "${WITH_METERING:-0}" == "1" ]]; then
    : "${METERING_INGEST_TOKEN:?Falta METERING_INGEST_TOKEN (System Account token con rol Ingest)}"
    KC_FILES+=(-f "${AIGW_DIA3}/config/demo_90_metering_billing.yaml")
  fi
  KC_FILES+=(--base-url "${KONNECT_API}" --pat "${KONNECT_TOKEN}")
}
kc_limpiar_tmp() { [[ -n "$KC_TMP" && -d "$KC_TMP" ]] && rm -rf "$KC_TMP"; KC_TMP=""; }

# Orden seguro (lecciones del demo track):
#  1. si hay vault/secretos (WITH_CLOUD=1) se aplican primero: si el DP resuelve
#     {vault://...} antes de que exista el secreto, cachea el error
#  2. apply: crea/actualiza
#  3. sync: borra lo que ya no está declarado
kc_deploy() {  # kc_deploy <NN> [--solucion]
  kc_archivos "$@"
  if [[ "${WITH_CLOUD:-0}" == "1" ]]; then
    kongctl apply -f "${KC_TMP}/00-gateway.yaml" -f "${AIGW_DIA3}/config/demo_05_secretos.yaml" \
      --base-url "${KONNECT_API}" --pat "${KONNECT_TOKEN}" --auto-approve >/dev/null || { kc_limpiar_tmp; return 1; }
  fi
  kongctl apply "${KC_FILES[@]}" --auto-approve >/dev/null || { kc_limpiar_tmp; return 1; }
  kongctl sync "${KC_FILES[@]}" --auto-approve; local rc=$?
  kc_limpiar_tmp; return $rc
}
kc_diff() { kc_archivos "$@"; kongctl diff "${KC_FILES[@]}"; local rc=$?; kc_limpiar_tmp; return $rc; }

# ---------- llamadas al AI Gateway -------------------------------------------
# llm <apikey> <model> <prompt> [curl-args...]  -> LLM_STATUS LLM_BODY LLM_HEADERS LLM_MS
now_ms() { python3 -c 'import time; print(int(time.time()*1000))'; }
llm() {
  local key=$1 model=$2 prompt=$3; shift 3
  local h b t0 auth=()
  [[ -n "$key" ]] && auth=(-H "apikey: ${key}")
  h=$(mktemp); b=$(mktemp); t0=$(now_ms)
  curl -s --max-time "${LLM_TIMEOUT:-180}" -D "$h" -o "$b" -X POST "${PROXY_URL}/v1/chat/completions" \
    ${auth[@]+"${auth[@]}"} -H "Content-Type: application/json" \
    -d "$(jq -cn --arg m "$model" --arg p "$prompt" '{model:$m, messages:[{role:"user",content:$p}]}')" "$@" || true
  LLM_MS=$(( $(now_ms) - t0 ))
  LLM_STATUS=$(awk 'NR==1{print $2}' "$h"); LLM_STATUS=${LLM_STATUS:-000}
  LLM_HEADERS=$(tr -d '\r' < "$h"); LLM_BODY=$(cat "$b"); rm -f "$h" "$b"
}
llm_answer() { { jq -r '.choices[0].message.content // .error.message // .message // empty' <<<"$LLM_BODY" 2>/dev/null || head -c 300 <<<"$LLM_BODY"; } | head -"${1:-4}" | sed 's/^/    │ /' || true; }
llm_usage()  { jq -r 'if .usage then "tokens: in=\(.usage.prompt_tokens) out=\(.usage.completion_tokens)" else "" end' <<<"$LLM_BODY" 2>/dev/null || true; }
llm_header() { grep -i "^$1:" <<<"$LLM_HEADERS" | head -1 | cut -d: -f2- | sed 's/^ *//' || true; }
llm_served() { local m; m=$(llm_header x-kong-llm-model); echo "${m:-$(jq -r '.model // empty' <<<"$LLM_BODY" 2>/dev/null)}"; }
check_llm() {  # check_llm "desc" <status> <apikey> <model> <prompt>
  local desc=$1 expected=$2; shift 2
  llm "$@"
  if [[ "$LLM_STATUS" == "$expected" ]]; then pass "$desc (HTTP $LLM_STATUS, ${LLM_MS} ms)"; else fail "$desc (esperado $expected, obtenido $LLM_STATUS)"; fi
  llm_answer
}
check() {  # check "desc" <status> <curl-args...>
  local desc=$1 expected=$2 code; shift 2
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 120 "$@" || true)
  if [[ "$code" == "$expected" ]]; then pass "$desc (HTTP $code)"; else fail "$desc (esperado $expected, obtenido $code)"; fi
}
check_retry() {  # reintenta hasta CHECK_TIMEOUT (default 90 s): propagación CP -> DP
  local desc=$1 expected=$2 code="" deadline; shift 2
  deadline=$(( $(date +%s) + ${CHECK_TIMEOUT:-90} ))
  while (( $(date +%s) < deadline )); do
    code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 120 "$@" || true)
    [[ "$code" == "$expected" ]] && { pass "$desc (HTTP $code)"; return 0; }
    sleep 3
  done
  fail "$desc (esperado $expected, último $code tras ${CHECK_TIMEOUT:-90}s)"
}
wait_for() {  # wait_for "desc" <timeout_s> <comando...>
  local desc=$1 timeout=$2 deadline; shift 2
  deadline=$(( $(date +%s) + timeout ))
  info "esperando: $desc (máx ${timeout}s)"
  until "$@" >/dev/null 2>&1; do
    (( $(date +%s) < deadline )) || { fail "timeout esperando: $desc"; return 1; }
    sleep 3
  done
  pass "$desc"
}
mcp() { python3 "${AIGW_ROOT}/scripts/mcp_client.py" "$@"; }   # mcp <url> <apikey> list|call ...

# ---------- espera de propagación CP -> DP --------------------------------------
# esperar_modelo <alias> [apikey]   reintenta hasta que el modelo responde 200
esperar_modelo() {
  local alias=$1 key=${2:-$AIGW_KEY_EQUIPO_DATOS}
  CHECK_TIMEOUT=${CHECK_TIMEOUT:-180} check_retry "modelo '${alias}' publicado en el Data Plane" 200 \
    -X POST "${PROXY_URL}/v1/chat/completions" -H "apikey: ${key}" -H "Content-Type: application/json" \
    -d "{\"model\":\"${alias}\",\"messages\":[{\"role\":\"user\",\"content\":\"Responde solo: OK\"}]}"
}
# esperar_ruta <path> [método]   reintenta hasta que la ruta existe (401 sin credencial)
esperar_ruta() {
  CHECK_TIMEOUT=${CHECK_TIMEOUT:-120} check_retry "ruta ${1} publicada (401 sin credencial)" 401 -X "${2:-POST}" "${PROXY_URL}${1}" \
    -H "Content-Type: application/json" -d '{}'
}
