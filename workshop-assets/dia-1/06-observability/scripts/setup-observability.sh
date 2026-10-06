#!/usr/bin/env bash
# ==============================================================================
# setup-observability.sh
# Levanta el stack de observabilidad del workshop:
#   OpenTelemetry Collector (:4317/:4318) + OpenObserve (:5080) + Arize Phoenix (:6006)
#
# Uso:
#   ./setup-observability.sh            # levanta (o actualiza) el stack y espera a que esté sano
#   ./setup-observability.sh status     # muestra estado y URLs
#   ./setup-observability.sh down       # detiene el stack (conserva los datos)
#   ./setup-observability.sh reset      # detiene y BORRA los datos (volúmenes) del stack
#
# Imágenes offline (opcional): si existe la carpeta ../docker-images con los .tar
# generados por save-images.sh, se cargan desde ahí en lugar de descargarse.
# Variable OTEL_IMAGES_DIR para usar otra carpeta.
# ==============================================================================

set -euo pipefail
cd "$(dirname "$0")/.."
BASE_DIR="$(pwd)"
STACK_DIR="${BASE_DIR}/otel-stack"
COMPOSE=(docker compose -f "${STACK_DIR}/docker-compose.yml")
ACTION="${1:-up}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

IMAGES=(
  "otel/opentelemetry-collector-contrib:0.161.0"
  "openobserve/openobserve:v1.0.4"
  "arizephoenix/phoenix:20.19.0"
)
IMAGES_DIR="${OTEL_IMAGES_DIR:-${BASE_DIR}/docker-images}"

# Credenciales: .env del stack (si existe) o valores por defecto del compose
if [ -f "${STACK_DIR}/.env" ]; then
  set -a; . "${STACK_DIR}/.env"; set +a
fi
ZO_ROOT_USER_EMAIL="${ZO_ROOT_USER_EMAIL:-admin@kong.com}"
ZO_ROOT_USER_PASSWORD="${ZO_ROOT_USER_PASSWORD:-Kong12345678!}"

print_access() {
  echo -e "\n${GREEN}======================================================${NC}"
  echo -e "${GREEN} Stack de observabilidad listo${NC}"
  echo -e "${GREEN}======================================================${NC}"
  echo -e " OpenObserve (traces, métricas, logs, dashboards): http://localhost:5080"
  echo -e "   Usuario:    ${ZO_ROOT_USER_EMAIL}"
  echo -e "   Contraseña: ${ZO_ROOT_USER_PASSWORD}"
  echo -e "   (organización 'default'; las señales llegan al stream 'default')"
  echo -e " Arize Phoenix (trazas orientadas a LLM/IA):       http://localhost:6006"
  echo -e "   Sin login. Cada service.name aparece como un proyecto."
  echo -e " OTLP (destino de Kong):"
  echo -e "   Desde el Data Plane (red kong-workshop): http://otel-collector:4318/v1/{traces,logs,metrics}"
  echo -e "   Desde el host:                           http://localhost:4318  (gRPC: localhost:4317)"
  echo -e "${GREEN}======================================================${NC}\n"
}

wait_for() {
  local name="$1" url="$2" tries="${3:-60}"
  printf "  Esperando %-16s" "${name}..."
  for _ in $(seq 1 "$tries"); do
    if curl -fsS -o /dev/null --max-time 3 "$url" 2>/dev/null; then
      echo -e " ${GREEN}OK${NC}"
      return 0
    fi
    sleep 2
  done
  echo -e " ${RED}TIMEOUT${NC} (${url})"
  return 1
}

# 1. Verificar Docker y Docker Compose
if ! command -v docker > /dev/null 2>&1 || ! docker info > /dev/null 2>&1; then
  echo -e "${RED}Error:${NC} Docker no está instalado o no está corriendo. Inicia Docker Desktop o el demonio de Docker y vuelve a intentar."
  exit 1
fi
if ! docker compose version > /dev/null 2>&1; then
  echo -e "${RED}Error:${NC} se requiere Docker Compose v2 ('docker compose')."
  exit 1
fi
if ! command -v curl > /dev/null 2>&1; then
  echo -e "${RED}Error:${NC} se requiere curl para verificar el estado del stack."
  exit 1
fi

case "$ACTION" in
  down)
    "${COMPOSE[@]}" down
    echo -e "${GREEN}Stack detenido (datos conservados).${NC}"
    exit 0
    ;;
  reset)
    "${COMPOSE[@]}" down -v
    echo -e "${GREEN}Stack detenido y datos eliminados.${NC}"
    exit 0
    ;;
  status)
    "${COMPOSE[@]}" ps
    print_access
    exit 0
    ;;
  up) ;;
  *)
    echo "Uso: $0 [up|status|down|reset]"
    exit 1
    ;;
esac

echo -e "${YELLOW}======================================================${NC}"
echo -e "${YELLOW} Inicializando stack de observabilidad (OTel)          ${NC}"
echo -e "${YELLOW} OpenTelemetry Collector + OpenObserve + Arize Phoenix ${NC}"
echo -e "${YELLOW}======================================================${NC}\n"

# 2. Imágenes: local -> .tar offline -> descarga
echo -e "${GREEN}[1/4] Verificando imágenes Docker...${NC}"
for img in "${IMAGES[@]}"; do
  if docker image inspect "$img" > /dev/null 2>&1; then
    echo -e "  ${GREEN}[LOCAL]${NC}  $img"
    continue
  fi
  tarfile="${IMAGES_DIR}/$(echo "$img" | tr '/:' '__').tar"
  if [ -f "$tarfile" ]; then
    echo -e "  ${YELLOW}[TAR]${NC}    $img <- $tarfile"
    docker load -i "$tarfile" > /dev/null
    continue
  fi
  echo -e "  ${YELLOW}[PULL]${NC}   $img"
  docker pull "$img"
done

# 3. Red compartida con el Data Plane de Kong
echo -e "\n${GREEN}[2/4] Verificando red Docker 'kong-workshop'...${NC}"
docker network inspect kong-workshop > /dev/null 2>&1 || docker network create kong-workshop > /dev/null
echo -e "  ${GREEN}[OK]${NC}     red kong-workshop disponible"

# 4. Levantar el stack
echo -e "\n${GREEN}[3/4] Levantando contenedores...${NC}"
"${COMPOSE[@]}" up -d

# 5. Esperar a que los servicios respondan
echo -e "\n${GREEN}[4/4] Esperando a que los servicios estén sanos...${NC}"
ok=true
wait_for "OpenObserve" "http://localhost:5080/healthz" || ok=false
wait_for "Phoenix" "http://localhost:6006/" || ok=false
wait_for "OTel Collector" "http://localhost:13133/" || ok=false

if [ "$ok" != true ]; then
  echo -e "\n${RED}Algún servicio no respondió a tiempo.${NC} Revisa los logs con:"
  echo "  docker compose -f \"${STACK_DIR}/docker-compose.yml\" logs --tail 50"
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q '^kong-dp$'; then
  echo -e "\n${YELLOW}Aviso:${NC} no se encontró el contenedor 'kong-dp'. Inícialo con docs/00-setup-entorno/scripts/start_dps.sh"
  echo "       (debe estar en la red kong-workshop para alcanzar http://otel-collector:4318)."
fi

print_access
