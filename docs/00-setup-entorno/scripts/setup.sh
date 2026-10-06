#!/usr/bin/env bash

cd "$(dirname "$0")/.."
set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$KONNECT_TOKEN" ] || [ "$KONNECT_TOKEN" == "kpat_XXXXXXXXX" ]; then
    echo -e "${RED}[ERROR] La variable KONNECT_TOKEN no está configurada correctamente. Es obligatoria.${NC}"
    exit 1
fi

if [ -z "$DEMO_PREFIX" ] || [ "$DEMO_PREFIX" == "tu_nombre" ]; then
    echo -e "${RED}[ERROR] La variable DEMO_PREFIX no está configurada correctamente. Es obligatoria.${NC}"
    exit 1
fi

echo -e "${YELLOW}======================================================${NC}"
echo -e "${YELLOW} Preparando Entorno para Ejercicio 000  ${NC}"
echo -e "${YELLOW}======================================================${NC}\n"

# 1. Levantar el mock backend (MockAPI)
echo -e "\n${GREEN}[1/3] Levantando backend simulado (MockAPI), OIDC, OPA y Kafka con Docker Compose...${NC}"
docker network create kong-workshop > /dev/null 2>&1 || true
docker compose up -d
# 2. Provisionar el Control Plane con Terraform
echo -e "\n${GREEN}[2/3] Creando Control Plane en Konnect (Terraform)...${NC}"

# Limpiamos el Control Plane usando decK por si quedaron objetos creados fuera de Terraform (evita colisiones de nombres)
echo -e "${YELLOW}Limpiando estado anterior del Control Plane (si existe)...${NC}"
deck gateway reset --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "${DEMO_PREFIX}_MockAPI" --force > /dev/null 2>&1 || true

cd terraform
# Fix for macOS Gatekeeper blocking the Terraform provider binary
xattr -r -d com.apple.quarantine . 2>/dev/null || true
# Ensure terraform providers are executable (often lost when unzipping)
chmod -R +x .terraform/providers/ 2>/dev/null || true
terraform init || echo "Asegúrate de tener Terraform instalado."
terraform apply -var="konnect_token=$KONNECT_TOKEN" -var="demo_prefix=$DEMO_PREFIX" -auto-approve
cd ..

# 3. Generar Certificados y levantar Data Planes
echo -e "\n${GREEN}[3/3] Generando certificados e iniciando Kong Data Plane...${NC}"
if ! python3 -c "import requests, cryptography" 2>/dev/null; then
    echo -e "${YELLOW}Instalando dependencias de Python (requests, cryptography)...${NC}"
    pip3 install -q requests cryptography || pip install -q requests cryptography
fi

if python3 scripts/generate_certs.py; then
    bash scripts/start_dps.sh
else
    echo -e "${RED}Hubo un error al generar los certificados. Asegúrate de tener los Control Planes creados y tus credenciales (KONNECT_TOKEN y DEMO_PREFIX) bien configuradas.${NC}"
fi

echo -e "\n${GREEN}======================================================${NC}"
echo -e "${GREEN} ¡Entorno listo! Ya puedes continuar con la creación de infraestructura.${NC}"
echo -e " MockAPI Backend: http://localhost:9081"
echo -e " Kong DP: http://localhost:8000"
echo -e "${GREEN}======================================================${NC}\n"
