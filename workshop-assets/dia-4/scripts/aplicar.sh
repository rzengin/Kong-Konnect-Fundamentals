#!/usr/bin/env bash
# =============================================================================
# workshop-assets/dia-4/scripts/aplicar.sh — aplica con kongctl la config del lab NN
#
#   aplicar.sh <NN> [--solucion] [--diff]
#
#   NN          00 = sólo base (gateway, proveedor Ollama, identidad) => deja el
#               AI Gateway LIMPIO de todo lo creado en los labs
#               01..09 = base + lab_01 ... lab_NN (los labs son acumulativos)
#   --solucion  usa workshop-assets/dia-4/soluciones/ en lugar de config/
#   --diff      sólo muestra qué cambiaría en Konnect (kongctl diff), no aplica
#
# Equivale a (ejemplo lab 02):
#   kongctl apply -f <00-gateway renderizado> -f config/base/10-proveedores.yaml \
#     -f config/base/15-identidad.yaml -f config/lab_01_multi_llm.yaml \
#     -f config/lab_02_gobierno_cuotas.yaml --base-url $KONNECT_ADDR --pat $KONNECT_TOKEN --auto-approve
#   kongctl sync  (mismos -f) --auto-approve
# =============================================================================
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
NN=${1:-}; shift || true
[[ "$NN" =~ ^[0-9]{1,2}$ ]] || die "uso: aplicar.sh <NN> [--solucion] [--diff]   (ej. aplicar.sh 02)"
MODO=""; SOLO_DIFF=0
for a in "$@"; do
  case "$a" in
    --solucion) MODO=--solucion ;;
    --diff) SOLO_DIFF=1 ;;
    *) die "opción desconocida: $a" ;;
  esac
done
require_cmd kongctl jq
require_env KONNECT_TOKEN DEMO_PREFIX
aigw_load_env
kongctl_version_ok || die "kongctl < ${KONGCTL_MIN_VERSION}: actualízalo (Lab IA 00)"

kc_archivos "$NN" "$MODO"
info "archivos: $(printf '%s\n' "${KC_FILES[@]}" | grep -E '\.yaml$' | sed "s#${REPO_ROOT}/##; s#${KC_TMP}/#(render)/#" | paste -sd' ' -)"
kc_limpiar_tmp

if (( SOLO_DIFF )); then
  step "kongctl diff (lab ${NN}${MODO:+, solución})"
  kc_diff "$NN" "$MODO"; exit $?
fi
step "kongctl apply + sync (lab ${NN}${MODO:+, solución})"
if kc_deploy "$NN" "$MODO"; then
  pass "configuración del lab ${NN} aplicada en tu AI Gateway"
  info "el Data Plane la recibe en unos segundos (propagación CP -> DP)"
else
  die "kongctl falló: revisa el YAML o ejecuta 'aplicar.sh ${NN} ${MODO} --diff'"
fi
