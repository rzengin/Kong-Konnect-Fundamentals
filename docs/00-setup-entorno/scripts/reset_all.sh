#!/usr/bin/env bash
# =============================================================================
# reset_all.sh — Reset Total del Workshop Kong Training
# =============================================================================
# Elimina TODOS los contenedores Docker del workshop, limpia los Control Planes
# en Konnect y deja el entorno listo para empezar desde cero.
#
# Uso:
#   ./scripts/reset_all.sh
#
# Requiere:
#   - Variables KONNECT_TOKEN y DEMO_PREFIX configuradas
#   - Docker corriendo
#   - decK CLI instalado
# =============================================================================

set -euo pipefail

echo "================================================="
echo " 🧹 RESET TOTAL — Kong Training Workshop"
echo "================================================="
echo ""

# --- 1. Configurar variables ---
if [ -z "${KONNECT_TOKEN:-}" ] || [ "${KONNECT_TOKEN}" == "kpat_XXXXXXXXX" ] || \
   [ -z "${DEMO_PREFIX:-}" ] || [ "${DEMO_PREFIX}" == "tu_nombre" ]; then
  echo " ❌ Error: Las variables KONNECT_TOKEN y DEMO_PREFIX deben estar configuradas correctamente."
  echo "    Ejecuta primero:"
  echo "      export KONNECT_TOKEN=\"kpat_...\""
  echo "      export DEMO_PREFIX=\"tu_nombre\""
  exit 1
fi

KONNECT_CONTROL_PLANE_NAME="${DEMO_PREFIX}_MockAPI"

# --- 2. Detener y eliminar contenedores y procesos del workshop ---
echo " [1/4] Deteniendo contenedores Docker y MkDocs..."
pkill -f "mkdocs serve" > /dev/null 2>&1 || true
CONTAINERS=(
  "kong-dp"
  "httpbin-backend"
  "mock-kong"
  "otel-collector"
  "openobserve"
  "phoenix"
)

for c in "${CONTAINERS[@]}"; do
  if docker ps -a --format '{{.Names}}' | grep -q "^${c}$"; then
    docker rm -f "$c" > /dev/null 2>&1 && echo "   ✅ Eliminado: $c" || echo "   ⚠️  No se pudo eliminar: $c"
  else
    echo "   ⏭️  No existe: $c"
  fi
done

# --- 3. Limpiar redes Docker huérfanas del workshop ---
echo ""
echo " [2/4] Limpiando redes Docker del workshop..."
for net in "ejercicio-001_default" "ejercicio-004_default" "otel-stack" "kong-workshop"; do
  if docker network ls --format '{{.Name}}' | grep -q "^${net}$"; then
    docker network rm "$net" > /dev/null 2>&1 && echo "   ✅ Red eliminada: $net" || echo "   ⚠️  No se pudo eliminar: $net (puede tener contenedores)"
  fi
done

# --- 4. Resetear Control Planes en Konnect ---
echo ""
echo " [3/4] Reseteando Control Plane en Konnect..."

echo -n "   Reseteando $KONNECT_CONTROL_PLANE_NAME... "
if deck gateway reset --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$KONNECT_CONTROL_PLANE_NAME" --force 2>/dev/null; then
  echo "✅"
else
  echo "⚠️  (puede no existir aún)"
fi

# --- 5. Limpiar archivos temporales generados ---
echo ""
echo " [4/4] Limpiando archivos temporales..."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Archivos generados por deck file merge (o equivalentes)
for f in "$PROJECT_DIR/release-external.yaml" "$PROJECT_DIR/release-internal.yaml" \
         "$PROJECT_DIR/../ejercicio-001/release-external.yaml" "$PROJECT_DIR/../ejercicio-001/release-internal.yaml" \
         "$PROJECT_DIR/release.yaml" "$PROJECT_DIR/estado-base.yaml"; do
  if [ -f "$f" ]; then
    rm -f "$f" && echo "   ✅ Eliminado: $(basename $f)"
  fi
done

echo ""
echo "================================================="
echo " ✅ RESET COMPLETO"
echo "================================================="
echo ""
echo " Para comenzar el workshop desde cero:"
echo "   cd 00-setup-entorno"
echo "   source scripts/set_env.sh"
echo "   # Seguir la guía: Guia_00_Setup_Entorno.md"
echo ""
