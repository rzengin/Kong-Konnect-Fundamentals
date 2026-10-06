#!/bin/bash
cd "$(dirname "$0")/.."
set -e

if [ ! -f endpoints.env ]; then
  echo "Error: falta endpoints.env (no se versiona). Ejecute primero: python3 scripts/generate_certs.py (ver endpoints.env.example)" >&2
  exit 1
fi
source endpoints.env
TOKEN=$KONNECT_TOKEN

EXT_CP_ID="f75082ae-c211-4b31-8e2e-509290c1e838"
INT_CP_ID="9085bc52-7ca9-4dc7-b16c-5194544c2fe4"

mkdir -p certs/external certs/internal

echo "Generating and uploading External CP cert..."
openssl req -new -x509 -nodes -days 365 -subj "/CN=kong-dp" -keyout certs/external/tls.key -out certs/external/tls.crt
CERT=$(cat certs/external/tls.crt)
CERT_JSON=$(python3 -c 'import sys, json; print(json.dumps({"cert": sys.argv[1]}))' "$CERT")
curl -s -X POST "https://us.api.konghq.com/v2/control-planes/${EXT_CP_ID}/dp-client-certificates" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$CERT_JSON" > /dev/null

echo "Generating and uploading Internal CP cert..."
openssl req -new -x509 -nodes -days 365 -subj "/CN=kong-dp" -keyout certs/internal/tls.key -out certs/internal/tls.crt
CERT=$(cat certs/internal/tls.crt)
CERT_JSON=$(python3 -c 'import sys, json; print(json.dumps({"cert": sys.argv[1]}))' "$CERT")
curl -s -X POST "https://us.api.konghq.com/v2/control-planes/${INT_CP_ID}/dp-client-certificates" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$CERT_JSON" > /dev/null

echo "Done."
