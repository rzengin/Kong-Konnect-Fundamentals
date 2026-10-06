#!/usr/bin/env bash

cd "$(dirname "$0")/.."
set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}======================================================${NC}"
echo -e "${YELLOW} Preparando Portal de Documentación (Solo Instructor) ${NC}"
echo -e "${YELLOW}======================================================${NC}\n"

if [ -f "../../mkdocs.yml" ]; then
    echo -e "\n${GREEN}[1/1] Levantando portal de documentación local...${NC}"
    pkill -f "mkdocs serve" > /dev/null 2>&1 || true
    (cd ../.. && if [ -f .venv/bin/mkdocs ]; then nohup .venv/bin/mkdocs serve -a 0.0.0.0:8001 > /tmp/mkdocs.log 2>&1 & else nohup python3 -m mkdocs serve -a 0.0.0.0:8001 > /tmp/mkdocs.log 2>&1 & fi)

    # La publicación en GitHub Pages la hace CI (.github/workflows/deploy-docs.yml) al hacer push a main,
    # después de validar el sitio con `mkdocs build --strict` y el chequeo de enlaces.
    
    echo -e "\n${GREEN}======================================================${NC}"
    echo -e "${GREEN} ¡Portal de documentación listo!${NC}"
    echo -e " Documentación Local: http://localhost:8001"
    echo -e "${GREEN}======================================================${NC}\n"
else
    echo -e "\n${RED}[ERROR] Archivo mkdocs.yml no encontrado. Asegúrate de estar en el repositorio principal.${NC}"
fi
