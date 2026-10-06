#!/bin/bash
# ============================================================
# Configuracion de variables de entorno - Kong Training
# ============================================================
# USO:  source set_env.sh
#
# Este script configura las variables necesarias para los
# ejercicios de Kong Training. Tiene dos modos:
#
#   1. AUTOMATICO: Usa la API de Konnect para descubrir los
#      Control Planes basandose en DEMO_PREFIX.
#
#   2. MANUAL: Edita las variables debajo si prefieres
#      configurarlas a mano.
# ============================================================

# ────────────────────────────────────────────────
# VARIABLES BASE (editar si es necesario)
# ────────────────────────────────────────────────

# Prefijo del participante (usado para nombrar los Control Planes)
export DEMO_PREFIX="${DEMO_PREFIX:-tu_nombre}"

# Token de Konnect (Personal Access Token)
export KONNECT_TOKEN="${KONNECT_TOKEN:-kpat_XXXXXXXXX}"

# Region de Konnect (us, eu, au)
export KONNECT_ADDR="${KONNECT_ADDR:-https://us.api.konghq.com}"

# ────────────────────────────────────────────────
# NOMBRES DE CONTROL PLANES (generados automaticamente)
# ────────────────────────────────────────────────

export KONNECT_CONTROL_PLANE_NAME="${DEMO_PREFIX}_MockAPI_External"
export KONNECT_CONTROL_PLANE_NAME="${DEMO_PREFIX}_MockAPI_Internal"
export KONNECT_CONTROL_PLANE_NAME="${DEMO_PREFIX}_MockAPI_Global"

# ────────────────────────────────────────────────
# IDs DE CONTROL PLANES
# ────────────────────────────────────────────────
# Opcion A: Dejar que el script los descubra automaticamente (ver abajo)
# Opcion B: Pegar los IDs manualmente aqui:

# export CP_ID="********-****-****-****-************"
# export CP_ID="********-****-****-****-************"
# export CP_ID="********-****-****-****-************"

# ────────────────────────────────────────────────
# AUTO-DESCUBRIMIENTO DE IDs (usa la API de Konnect)
# ────────────────────────────────────────────────

echo ""
echo "================================================"
echo " Kong Training - Configuracion de Entorno"
echo "================================================"
echo " Participante:  $DEMO_PREFIX"
echo " Konnect:       $KONNECT_ADDR"
echo "------------------------------------------------"

# Funcion para buscar el ID de un Control Plane por nombre
find_cp_id() {
    local cp_name="$1"
    local cp_id

    cp_id=$(curl -s -H "Authorization: Bearer ${KONNECT_TOKEN}" \
        "${KONNECT_ADDR}/v2/control-planes" \
        | python3 -c "
import sys, json
data = json.load(sys.stdin)
for cp in data.get('data', []):
    if cp.get('name') == '${cp_name}':
        print(cp['id'])
        break
" 2>/dev/null)

    echo "$cp_id"
}

# Buscar IDs si no estan definidos manualmente
if [ -z "$CP_ID" ]; then
    echo " Buscando Control Plane: $KONNECT_CONTROL_PLANE_NAME ..."
    CP_ID=$(find_cp_id "$KONNECT_CONTROL_PLANE_NAME")
    if [ -n "$CP_ID" ]; then
        export CP_ID
        echo "   -> ID: $CP_ID"
    else
        echo "   -> No encontrado. Crealo primero en Konnect."
    fi
fi

if [ -z "$CP_ID" ]; then
    echo " Buscando Control Plane: $KONNECT_CONTROL_PLANE_NAME ..."
    CP_ID=$(find_cp_id "$KONNECT_CONTROL_PLANE_NAME")
    if [ -n "$CP_ID" ]; then
        export CP_ID
        echo "   -> ID: $CP_ID"
    else
        echo "   -> No encontrado. Crealo primero en Konnect."
    fi
fi

if [ -z "$CP_ID" ]; then
    echo " Buscando Control Plane: $KONNECT_CONTROL_PLANE_NAME ..."
    CP_ID=$(find_cp_id "$KONNECT_CONTROL_PLANE_NAME")
    if [ -n "$CP_ID" ]; then
        export CP_ID
        echo "   -> ID: $CP_ID"
    else
        echo "   -> No encontrado. Crealo primero en Konnect."
    fi
fi

echo "------------------------------------------------"

# ────────────────────────────────────────────────
# DETECCION DE IP DEL HOST DOCKER
# ────────────────────────────────────────────────
# Kong corre en Docker y ve la IP del gateway Docker, no 127.0.0.1.
# Esta variable se usa en los archivos decK con ${{ env "DECK_DOCKER_HOST_IP" }}.

if [ -z "$DECK_DOCKER_HOST_IP" ]; then
    echo " Detectando IP del host Docker..."
    
    # En Docker Desktop (Mac/Windows), la IP del host vista por los contenedores
    # es siempre 192.168.65.1. En Linux nativo, es el gateway del bridge.
    # Detectamos el SO para elegir el metodo correcto.
    case "$(uname -s)" in
        Darwin|MINGW*|MSYS*|CYGWIN*)
            # Docker Desktop para Mac/Windows
            DECK_DOCKER_HOST_IP="192.168.65.1"
            ;;
        Linux)
            # Docker nativo en Linux: usar el gateway del bridge
            DECK_DOCKER_HOST_IP=$(docker network inspect bridge --format '{{range .IPAM.Config}}{{.Gateway}}{{end}}' 2>/dev/null)
            if [ -z "$DECK_DOCKER_HOST_IP" ]; then
                DECK_DOCKER_HOST_IP="172.17.0.1"
            fi
            ;;
        *)
            DECK_DOCKER_HOST_IP="192.168.65.1"
            ;;
    esac
    
    echo "   -> $DECK_DOCKER_HOST_IP ($(uname -s))"
    export DECK_DOCKER_HOST_IP
fi

echo "------------------------------------------------"
echo ""
echo " Variables configuradas:"
echo "   KONNECT_CONTROL_PLANE_NAME = $KONNECT_CONTROL_PLANE_NAME"
echo "   CP_ID   = ${CP_ID:-NO DEFINIDO}"
echo ""
echo "   KONNECT_CONTROL_PLANE_NAME = $KONNECT_CONTROL_PLANE_NAME"
echo "   CP_ID   = ${CP_ID:-NO DEFINIDO}"
echo ""
echo "   KONNECT_CONTROL_PLANE_NAME   = $KONNECT_CONTROL_PLANE_NAME"
echo "   CP_ID     = ${CP_ID:-NO DEFINIDO}"
echo ""
echo "   DECK_DOCKER_HOST_IP   = $DECK_DOCKER_HOST_IP"
echo ""
echo "================================================"
echo ""

