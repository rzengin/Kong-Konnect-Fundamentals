#!/usr/bin/env bash
# =============================================================================
# workshop-assets/dia-4/scripts/teardown.sh [--all]
#   (sin flags)  baja los contenedores del Día 4 (la config queda en Konnect)
#   --all        además borra volúmenes (modelos de Ollama, Redis) y el estado local
#                ($AIGW_STATE_DIR: certificado y API keys). Para limpiar también tu
#                AI Gateway en Konnect ejecuta antes: aplicar.sh 00
# =============================================================================
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
aigw_load_env
if [[ "${1:-}" == "--all" ]]; then
  dc --profile ollama --profile compresion --profile pii down -v --remove-orphans
  [[ -d "$AIGW_STATE_DIR" ]] && rm -rf "$AIGW_STATE_DIR" && info "estado local borrado: ${AIGW_STATE_DIR}"
  warn "Recuerda borrar el certificado del DP 'aigw-lab-${DEMO_PREFIX}' en Konnect (AI Gateway > Data Plane Nodes) si no vas a reutilizar el gateway."
else
  dc --profile ollama --profile compresion --profile pii down --remove-orphans
fi
pass "contenedores del Día 4 detenidos"
