#!/bin/bash
cd "$(dirname "$0")/.."
set -e
if [ ! -f endpoints.env ]; then
  echo "Error: falta endpoints.env (no se versiona). Ejecute primero: python3 scripts/generate_certs.py (ver endpoints.env.example)" >&2
  exit 1
fi
source endpoints.env

docker rm -f kong-dp-external kong-dp-internal 2>/dev/null || true

# Create the workshop network if it doesn't exist
docker network create kong-workshop 2>/dev/null || true

echo "Starting kong-dp-external..."
docker run -d --name kong-dp-external \
  --network kong-workshop \
  -p 28000:28000 -p 28443:28443 \
  -e "KONG_ROLE=data_plane" \
  -e "KONG_DATABASE=off" \
  -e "KONG_CLUSTER_MTLS=pki" \
  -e "KONG_CLUSTER_CONTROL_PLANE=$EXTERNAL_CONTROL:443" \
  -e "KONG_CLUSTER_TELEMETRY_ENDPOINT=$EXTERNAL_TELEMETRY:443" \
  -e "KONG_CLUSTER_CERT=/certs/tls.crt" \
  -e "KONG_CLUSTER_CERT_KEY=/certs/tls.key" \
  -e "KONG_LUA_SSL_TRUSTED_CERTIFICATE=system" \
  -e "KONG_KONNECT_MODE=on" \
  -e "KONG_VITALS=off" \
  -e "KONG_TRACING_INSTRUMENTATIONS=all" \
  -e "KONG_TRACING_SAMPLING_RATE=1.0" \
  -e "KONG_PROXY_LISTEN=0.0.0.0:28000, 0.0.0.0:28443 ssl" \
  -v "$(pwd)/certs/external:/certs" \
  kong/kong-gateway:latest

echo "Starting kong-dp-internal..."
docker run -d --name kong-dp-internal \
  --network kong-workshop \
  -p 18000:18000 -p 18443:18443 \
  -e "KONG_ROLE=data_plane" \
  -e "KONG_DATABASE=off" \
  -e "KONG_CLUSTER_MTLS=pki" \
  -e "KONG_CLUSTER_CONTROL_PLANE=$INTERNAL_CONTROL:443" \
  -e "KONG_CLUSTER_TELEMETRY_ENDPOINT=$INTERNAL_TELEMETRY:443" \
  -e "KONG_CLUSTER_CERT=/certs/tls.crt" \
  -e "KONG_CLUSTER_CERT_KEY=/certs/tls.key" \
  -e "KONG_LUA_SSL_TRUSTED_CERTIFICATE=system" \
  -e "KONG_KONNECT_MODE=on" \
  -e "KONG_VITALS=off" \
  -e "KONG_TRACING_INSTRUMENTATIONS=all" \
  -e "KONG_TRACING_SAMPLING_RATE=1.0" \
  -e "KONG_PROXY_LISTEN=0.0.0.0:18000, 0.0.0.0:18443 ssl" \
  -v "$(pwd)/certs/internal:/certs" \
  kong/kong-gateway:latest

echo "Done."
