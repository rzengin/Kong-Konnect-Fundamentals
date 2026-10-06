#!/usr/bin/env bash
# =============================================================================
# workshop-assets/dia-4/scripts/reset_vectores.sh — borra de Redis los vectores
# del enrutamiento semántico (modelo "auto"). Necesario después de cambiar una
# semantic_description o el threshold (Lab IA 04): el DP los recrea en el
# próximo request.   --cache  además vacía la caché semántica.
# =============================================================================
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
aigw_load_env
running aigw-lab-redis || die "Redis (aigw-lab-redis) no está corriendo"
patrones=('semantic_routing:*')
[[ "${1:-}" == "--cache" ]] && patrones+=('*semantic_cache*' 'kong_semantic_cache*')
n=0
for p in "${patrones[@]}"; do
  for k in $(redis_cli --scan --pattern "$p" 2>/dev/null); do redis_cli DEL "$k" >/dev/null; n=$((n+1)); done
done
pass "${n} claves borradas (${patrones[*]}). El Data Plane las recrea en el próximo request."
