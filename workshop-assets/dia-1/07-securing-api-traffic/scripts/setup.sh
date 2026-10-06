#!/usr/bin/env bash

cd "$(dirname "$0")/.."
set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}======================================================${NC}"
echo -e "${YELLOW} Preparando Entorno para Ejercicio 001  ${NC}"
echo -e "${YELLOW}======================================================${NC}\n"

# 1. Levantar el mock backend (MockAPI)
echo -e "\n${GREEN}[1/1] Levantando backend simulado (MockAPI) con Docker Compose...${NC}"
docker compose up -d

echo -e "\n${GREEN}======================================================${NC}"
echo -e "${GREEN} ¡Backend listo! Ya puedes continuar con la creación de infraestructura.${NC}"
echo -e " MockAPI Backend: http://localhost:9081"
echo -e "${GREEN}======================================================${NC}\n"
