#!/usr/bin/env bash
# ==============================================================================
# save-images.sh
# Descarga y exporta (docker save) las imágenes del stack de observabilidad para
# entornos sin internet. Genera ../docker-images/*.tar (no se versionan: .gitignore).
#
# En la máquina destino, setup-observability.sh carga automáticamente los .tar
# (docker load) si las imágenes no están en Docker. También puedes cargarlas a mano:
#   for f in docker-images/*.tar; do docker load -i "$f"; done
# ==============================================================================

set -euo pipefail
cd "$(dirname "$0")/.."

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

IMAGES_DIR="${OTEL_IMAGES_DIR:-docker-images}"
mkdir -p "$IMAGES_DIR"

# Imágenes del stack (deben coincidir con otel-stack/docker-compose.yml)
IMAGES=(
  "otel/opentelemetry-collector-contrib:0.161.0"
  "openobserve/openobserve:v1.0.4"
  "arizephoenix/phoenix:20.19.0"
)

echo -e "${YELLOW}======================================================${NC}"
echo -e "${YELLOW} Guardando imágenes del stack de observabilidad (OTel) ${NC}"
echo -e "${YELLOW}======================================================${NC}\n"

for img in "${IMAGES[@]}"; do
  tarfile="${IMAGES_DIR}/$(echo "$img" | tr '/:' '__').tar"

  if [ -f "$tarfile" ]; then
    echo -e "${GREEN}[EXISTE]${NC} $tarfile — saltando"
    continue
  fi

  echo -e "${YELLOW}[PULL]${NC} $img ..."
  docker pull "$img"

  echo -e "${YELLOW}[SAVE]${NC} $img -> $tarfile ..."
  docker save "$img" -o "$tarfile"

  echo -e "${GREEN}[OK]${NC} $(du -h "$tarfile" | cut -f1) guardados\n"
done

echo -e "\n${GREEN}======================================================${NC}"
echo -e "${GREEN} Imágenes guardadas en ${IMAGES_DIR}/${NC}"
echo -e "${GREEN} Distribuye esta carpeta por USB o drive y ejecuta${NC}"
echo -e "${GREEN} scripts/setup-observability.sh en la máquina destino.${NC}"
echo -e "${GREEN}======================================================${NC}\n"
ls -lh "$IMAGES_DIR"/*.tar
