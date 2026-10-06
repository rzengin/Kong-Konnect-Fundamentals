#!/usr/bin/env bash
# ============================================================
# Generador de JWT (HS256) para Workshop Kong - Módulo 002
# Uso: ./scripts/generate_jwt.sh [duracion_en_horas]
# Requiere: openssl (preinstalado en Mac/Linux)
# ============================================================

set -e

SECRET="${JWT_SECRET:-my-super-secret-key-for-workshop}"
ISSUER="${JWT_ISSUER:-mock-jwt-issuer}"
DURATION_HOURS="${1:-1}"

# Calcular timestamps
IAT=$(date +%s)
if [[ "$OSTYPE" == "darwin"* ]]; then
    EXP=$(date -v+"${DURATION_HOURS}"H +%s)
else
    EXP=$(date -d "+${DURATION_HOURS} hour" +%s)
fi

# Función auxiliar para base64url encoding
base64url() {
    openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n'
}

# Construir JWT
HEADER=$(echo -n '{"alg":"HS256","typ":"JWT"}' | base64url)
PAYLOAD=$(echo -n "{\"iss\":\"${ISSUER}\",\"exp\":${EXP},\"sub\":\"App-JWT\",\"iat\":${IAT}}" | base64url)
SIGNATURE=$(echo -n "${HEADER}.${PAYLOAD}" | openssl dgst -sha256 -hmac "${SECRET}" -binary | base64url)

JWT="${HEADER}.${PAYLOAD}.${SIGNATURE}"

echo ""
echo "═══════════════════════════════════════════════════════"
echo " JWT generado exitosamente (válido por ${DURATION_HOURS}h)"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Token:"
echo "${JWT}"
echo ""
echo "Para usar con curl:"
echo "  export JWT_TOKEN=\"${JWT}\""
echo "  curl -k -i -X GET http://localhost:28000/echo -H \"Authorization: Bearer \$JWT_TOKEN\""
echo ""
