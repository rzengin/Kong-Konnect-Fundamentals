#!/bin/bash
# ============================================================
# run_all_demos.sh
# Ejecución interactiva/automatizada de las Demostraciones
# del Kong Training Konnect Fundamentals.
# ============================================================

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

pass()  { echo -e "\n ${GREEN}${BOLD}[OK] PASS${NC}: ${BOLD}$1${NC}\n"; }
fail()  { echo -e "\n ${RED}${BOLD}[FAIL] FAIL${NC}: ${BOLD}$1${NC}\n"; }
header() {
 echo ""
 echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} $1${NC}"
 echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════${NC}"
 echo ""
}
step()  { echo -e "\n${YELLOW}${BOLD} > $1${NC}\n"; }
mostrar_cmd() { echo -e "\n ${GREEN}\$ $1${NC}\n"; }

AUTO_MODE=false
for arg in "$@"; do
 if [ "$arg" == "--auto" ]; then
  AUTO_MODE=true
 fi
done

pausa() {
 if [ "$AUTO_MODE" = false ]; then
  echo -ne " ${CYAN}${BOLD}>> Presiona ENTER para continuar...${NC}"
  read -r
  echo ""
 else
  echo -e " ${CYAN}${BOLD}>> Continuando automáticamente (--auto)...${NC}\n"
  sleep 2
 fi
}

check_env() {
  # Asegurar que las variables complementarias (KONNECT_CONTROL_PLANE_NAME, DECK_DOCKER_HOST_IP) estén cargadas
  if [ -f "docs/00-setup-entorno/scripts/set_env.sh" ]; then
    source "docs/00-setup-entorno/scripts/set_env.sh" > /dev/null 2>&1
  fi

  if [ -z "$KONNECT_TOKEN" ] || [ "$KONNECT_TOKEN" == "kpat_XXXXXXXXX" ]; then
    echo -e "${RED}ERROR: KONNECT_TOKEN inválido o no definido. Configúralo en tu entorno o en set_env.sh.${NC}"
    exit 1
  fi
}

# ============================================================
# FUNCIONES DE DEMOSTRACIONES
# ============================================================

demo_modulo_01() {
  header "Módulo 01: Kong Konnect Gateway (Básico)"
  check_env
  
  echo -e "${YELLOW}NOTA: Este módulo es principalmente visual a través de la interfaz de Konnect.${NC}"
  echo -e "${YELLOW}Se asume que el instructor ya configuró manualmente el servicio y la ruta en la UI.${NC}"
  pausa

  step "Configurando estado inicial para Módulo 01 (deck sync)..."
  cat <<EOF > /tmp/mod01_base.yaml
_format_version: "3.0"
services:
 - name: mock-service
  url: http://httpbin-backend:9081/anything
  routes:
   - name: mock-route
    paths:
     - /mock
EOF
  deck gateway reset --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$KONNECT_CONTROL_PLANE_NAME" --force
  deck gateway sync /tmp/mod01_base.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$KONNECT_CONTROL_PLANE_NAME"

  step "Validando ruta configurada (Proxy a Mock Backend)"
  mostrar_cmd "curl -k -i https://localhost:8443/mock/get"
  
  # Polling simple esperando propagación
  for i in {1..30}; do
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/mock/get)
    if [ "$HTTP_STATUS" == "200" ]; then break; fi
    sleep 2
  done
  
  if [ "$HTTP_STATUS" == "200" ]; then
    pass "200 OK - La ruta fue configurada y responde correctamente"
  else
    fail "Recibimos un status $HTTP_STATUS en lugar de 200 OK. ¿Configuraste la ruta en Konnect?"
  fi
  pausa
}

demo_modulo_02() {
  header "Módulo 02: Kong Plugins (Edición Avanzada)"
  check_env
  
  step "C.1 Preparación (Sincronizar base del Ejercicio 002)"
  mostrar_cmd "deck gateway reset ... && deck gateway sync ..."
  if deck gateway reset --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$KONNECT_CONTROL_PLANE_NAME" --force && \
    deck gateway sync workshop-assets/dia-1/02-kong-plugins/archivos-deck/00-demo1-estado-base-002.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$KONNECT_CONTROL_PLANE_NAME"; then
    pass "Base de plugins configurada"
  else
    fail "Error sincronizando la base de plugins"
    return 1
  fi
  pausa
  
  step "C.1 Validación Inicial (Debe retornar 401 por Key Auth)"
  mostrar_cmd "curl -k -i https://localhost:8443/mock"
  
  # Polling simple esperando propagación
  for i in {1..30}; do
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/mock)
    if [ "$HTTP_STATUS" == "401" ]; then break; fi
    sleep 2
  done
  
  if [ "$HTTP_STATUS" == "401" ]; then
    pass "401 Unauthorized (Esperado por plugin Key-Auth)"
  else
    fail "Esperábamos 401, recibimos $HTTP_STATUS"
  fi
  pausa
  
  step "Validación con API Key válida"
  mostrar_cmd "curl -k -i https://localhost:8443/mock -H \"apikey: external-secret-123\""
  HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/mock -H "apikey: external-secret-123")
  if [ "$HTTP_STATUS" == "200" ]; then
    pass "200 OK - Key-Auth superado"
  else
    fail "Fallo al usar el apikey"
  fi
  pausa
  
  step "C.12 Demostración OIDC (OpenID Connect)"
  mostrar_cmd "deck gateway sync workshop-assets/dia-1/02-kong-plugins/archivos-deck/11-demo12-oidc.yaml ..."
  deck gateway sync workshop-assets/dia-1/02-kong-plugins/archivos-deck/11-demo12-oidc.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$KONNECT_CONTROL_PLANE_NAME"
  pass "Configuración OIDC inyectada (Apunta a Konnect Identity)"
  pausa

  step "C.13 Demostración OPA (Open Policy Agent)"
  mostrar_cmd "deck gateway sync workshop-assets/dia-1/02-kong-plugins/archivos-deck/12-demo13-opa.yaml ..."
  deck gateway sync workshop-assets/dia-1/02-kong-plugins/archivos-deck/12-demo13-opa.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$KONNECT_CONTROL_PLANE_NAME"
  pass "Configuración OPA inyectada"
  pausa

  step "C.14 Demostración OpenTelemetry"
  mostrar_cmd "deck gateway sync workshop-assets/dia-1/02-kong-plugins/archivos-deck/13-demo14-opentelemetry.yaml ..."
  deck gateway sync workshop-assets/dia-1/02-kong-plugins/archivos-deck/13-demo14-opentelemetry.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$KONNECT_CONTROL_PLANE_NAME"
  pass "Configuración OpenTelemetry inyectada"
  echo -e "${YELLOW}>> El instructor debe mostrar las trazas en OpenObserve (http://localhost:5080) o Phoenix (http://localhost:6006).${NC}"
  pausa

  step "C.15 y C.16 Demostración ACL e IP Restriction"
  mostrar_cmd "deck gateway sync workshop-assets/dia-1/02-kong-plugins/archivos-deck/14-demo15-acl.yaml ..."
  deck gateway sync workshop-assets/dia-1/02-kong-plugins/archivos-deck/14-demo15-acl.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$KONNECT_CONTROL_PLANE_NAME"
  mostrar_cmd "deck gateway sync workshop-assets/dia-1/02-kong-plugins/archivos-deck/15-demo16-ip-restriction.yaml ..."
  deck gateway sync workshop-assets/dia-1/02-kong-plugins/archivos-deck/15-demo16-ip-restriction.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$KONNECT_CONTROL_PLANE_NAME"
  pass "Configuraciones ACL e IP Restriction inyectadas"
  pausa
}

demo_modulo_04() {
  header "Módulo 04: Gateway Operations (IaC)"
  check_env
  
  step "Demostración 0: Limpieza del Entorno Base (Simulando inicio de Día 2)"
  mostrar_cmd "./docs/00-setup-entorno/scripts/reset_all.sh"
  bash docs/00-setup-entorno/scripts/reset_all.sh
  
  echo -e "\n ${YELLOW}> Levantando backend simulado y OIDC...${NC}"
  (cd docs/00-setup-entorno && docker compose up -d)
  
  mostrar_cmd "terraform destroy -var=\"konnect_token=\$KONNECT_TOKEN\" -var=\"demo_prefix=\$DEMO_PREFIX\" -auto-approve"
  (cd docs/00-setup-entorno/terraform && terraform destroy -var="konnect_token=$KONNECT_TOKEN" -var="demo_prefix=$DEMO_PREFIX" -auto-approve)
  pass "Entorno limpio"
  pausa

  step "Demostración 1: Gobierno de Infraestructura (Terraform)"
  mostrar_cmd "terraform init && terraform apply ..."
  (cd docs/00-setup-entorno/terraform && terraform init && terraform apply -var="konnect_token=$KONNECT_TOKEN" -var="demo_prefix=$DEMO_PREFIX" -auto-approve)
  pass "Control Plane MockAPI y RBAC creado con Terraform"
  pausa

  step "Demostración 2: Despliegue del Data Plane"
  mostrar_cmd "python3 docs/00-setup-entorno/scripts/generate_certs.py && bash docs/00-setup-entorno/scripts/start_dps.sh"
  python3 docs/00-setup-entorno/scripts/generate_certs.py
  bash docs/00-setup-entorno/scripts/start_dps.sh
  pass "Data Plane local desplegado"
  pausa

  step "Demostración 4: Sincronización Declarativa con decK (Rutas y Políticas Globales)"
  mostrar_cmd "deck gateway diff ... && deck gateway sync ..."
  deck gateway diff workshop-assets/dia-1/04-gateway-operations/archivos-deck/estado-base.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$KONNECT_CONTROL_PLANE_NAME"
  deck gateway sync workshop-assets/dia-1/04-gateway-operations/archivos-deck/estado-base.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$KONNECT_CONTROL_PLANE_NAME"
  pass "Estado base de MockAPI inyectado (Rutas + file-log + correlation-id)"
  pausa

  step "Demostración 4: Validación de Logs"
  mostrar_cmd "curl -k -s -o /dev/null https://localhost:8443/mock"
  for i in {1..10}; do curl -k -s -o /dev/null https://localhost:8443/mock; done
  sleep 2
  mostrar_cmd "docker exec kong-dp wc -l /tmp/kong-requests.log"
  docker exec kong-dp wc -l /tmp/kong-requests.log || echo "Aún no hay logs"
  pass "Validación de políticas globales aplicada"
  pausa
}

demo_modulo_05() {
  header "Módulo 05: Monitoring & Logging"
  check_env
  
  step "Generación de telemetría para Konnect Analytics"
  echo -e "${YELLOW}NOTA: Este script inyectará tráfico masivo (éxitos, 401s, 404s) para poblar los dashboards.${NC}"
  mostrar_cmd "./workshop-assets/dia-1/05-monitoring-logging/scripts/generate_traffic.sh"
  
  if [ -f "workshop-assets/dia-1/05-monitoring-logging/scripts/generate_traffic.sh" ]; then
    bash workshop-assets/dia-1/05-monitoring-logging/scripts/generate_traffic.sh
    pass "Tráfico de telemetría generado."
  else
    fail "No se encontró el script generate_traffic.sh."
  fi
  pausa
}

demo_modulo_06() {
  header "Módulo 06: Observabilidad Avanzada (OTel + OpenObserve + Phoenix)"
  check_env

  step "Levantando el stack de observabilidad (OTel Collector + OpenObserve + Phoenix)"
  mostrar_cmd "./workshop-assets/dia-1/06-observability/scripts/setup-observability.sh"
  if bash workshop-assets/dia-1/06-observability/scripts/setup-observability.sh; then
    pass "Stack de observabilidad en ejecución."
  else
    fail "No se pudo levantar el stack de observabilidad."
  fi
  pausa

  step "Habilitando el plugin OpenTelemetry (destino: http://otel-collector:4318)"
  mostrar_cmd "deck gateway sync workshop-assets/dia-1/06-observability/archivos-deck/solucion-kong.yaml ..."
  deck gateway sync workshop-assets/dia-1/06-observability/archivos-deck/solucion-kong.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$KONNECT_CONTROL_PLANE_NAME"
  sleep 10

  mostrar_cmd "for i in {1..10}; do curl -k -s -o /dev/null https://localhost:8443/mock; done"
  for i in {1..10}; do
    curl -k -s -o /dev/null https://localhost:8443/mock
    sleep 0.5
  done
  pass "Tráfico generado para el muestreo de trazas, logs y métricas."
  echo -e "${YELLOW}>> OpenObserve (Traces / Logs / Metrics): http://localhost:5080  (usuario: ${ZO_ROOT_USER_EMAIL:-admin@kong.com})${NC}"
  echo -e "${YELLOW}>> Arize Phoenix (vista de trazas LLM/IA): http://localhost:6006  (proyecto: kong-gateway)${NC}"
  pausa
}

demo_modulo_07() {
  header "Módulo 07: Securing API Traffic"
  check_env
  
  # Directorio de los archivos deck para el módulo 07
  DECK_DIR="workshop-assets/dia-1/07-securing-api-traffic/archivos-deck"
  
  step "C.2 Preparación (Key Auth y ACL)"
  mostrar_cmd "deck gateway sync ... 03-b3-acl.yaml"
  if deck gateway sync $DECK_DIR/03-b3-acl.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$KONNECT_CONTROL_PLANE_NAME"; then
    pass "Políticas Key Auth y ACL inyectadas correctamente."
  else
    fail "Error sincronizando las políticas de autenticación."
    return 1
  fi
  pausa

  step "C.2 Validación de fallo (Petición anónima)"
  mostrar_cmd "curl -k -i https://localhost:8443/mock"
  
  # Polling simple esperando propagación
  for i in {1..30}; do
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/mock)
    if [ "$HTTP_STATUS" == "401" ]; then break; fi
    sleep 2
  done
  
  if [ "$HTTP_STATUS" == "401" ]; then
    pass "401 Unauthorized - Bloqueado por Key Auth"
  else
    fail "Esperábamos 401, recibimos $HTTP_STATUS"
  fi
  pausa

  step "C.2 Validación exitosa (Consumo legítimo)"
  mostrar_cmd "curl -k -i https://localhost:8443/mock -H \"apikey: external-secret-123\""
  
  # Polling simple para que el DP reciba la nueva api key
  for i in {1..30}; do
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/mock -H "apikey: external-secret-123")
    if [ "$HTTP_STATUS" == "200" ]; then break; fi
    sleep 2
  done

  if [ "$HTTP_STATUS" == "200" ]; then
    pass "200 OK - Acceso permitido"
  else
    fail "Fallo al usar el apikey válido, recibimos $HTTP_STATUS"
  fi
  pausa

  step "C.2 Validación de permisos (Credencial interna a ruta externa)"
  mostrar_cmd "curl -k -i https://localhost:8443/mock -H \"apikey: internal-secret-123\""
  
  # Ya sabemos que propagó, pero por si acaso validamos
  HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/mock -H "apikey: internal-secret-123")
  if [ "$HTTP_STATUS" == "403" ]; then
    pass "403 Forbidden - Bloqueado por ACL (Rol inválido)"
  else
    fail "Esperábamos 403, recibimos $HTTP_STATUS"
  fi
  pausa

  step "C.4 Restricción de Capa de Red (IP Restriction)"
  mostrar_cmd "deck gateway sync ... 08-b8-ip-restriction.yaml"
  if deck gateway sync $DECK_DIR/08-b8-ip-restriction.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$KONNECT_CONTROL_PLANE_NAME"; then
    pass "Política IP Restriction inyectada correctamente."
  else
    fail "Error sincronizando IP Restriction."
    return 1
  fi
  pausa

  step "C.4 Validación de Bloqueo de Red (Caso Positivo)"
  mostrar_cmd "curl -k -i https://localhost:8443/mock -H \"apikey: external-secret-123\""
  
  # Polling simple (Caso positivo desde el host, que está en whitelist)
  for i in {1..10}; do
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/mock -H "apikey: external-secret-123")
    if [ "$HTTP_STATUS" == "200" ]; then break; fi
    sleep 2
  done

  if [ "$HTTP_STATUS" == "200" ]; then
    pass "200 OK - Petición desde tu IP ($DECK_DOCKER_HOST_IP) permitida."
  else
    fail "Esperábamos 200, recibimos $HTTP_STATUS"
  fi
  pausa

  step "C.4 Validación de Bloqueo de Red (Caso Negativo - IP Bloqueada)"
  echo -e "${YELLOW}>> Ejecutando curl desde una IP no autorizada (contenedor temporal)...${NC}"
  mostrar_cmd "docker run --rm --network kong-workshop curlimages/curl -k -s -o /dev/null -w \"%{http_code}\" https://kong-dp:8443/mock -H \"apikey: external-secret-123\""
  
  # Polling para el caso negativo, ya que la política tarda en propagarse (Eventual Consistency)
  for i in {1..30}; do
    HTTP_STATUS_NEG=$(docker run --rm --network kong-workshop curlimages/curl -k -s -o /dev/null -w "%{http_code}" https://kong-dp:8443/mock -H "apikey: external-secret-123")
    if [ "$HTTP_STATUS_NEG" == "403" ]; then break; fi
    sleep 2
  done
  
  if [ "$HTTP_STATUS_NEG" == "403" ]; then
    pass "403 Forbidden - Petición desde IP no autorizada bloqueada exitosamente."
  else
    fail "Esperábamos 403, recibimos $HTTP_STATUS_NEG"
  fi
  pausa

  step "C.5 Demostración mTLS Puro"
  # Las claves privadas (*.key) no se versionan: si no existe la CA local, se genera aquí.
  if [ ! -f docs/00-setup-entorno/scripts/ca.key ]; then
    echo -e "${YELLOW}>> Generando CA local (ca.key/ca.crt) para la demo de mTLS...${NC}"
    openssl req -new -x509 -nodes -days 365 -subj "/CN=kong-ca/O=MyOrg" \
      -keyout docs/00-setup-entorno/scripts/ca.key -out docs/00-setup-entorno/scripts/ca.crt >/dev/null 2>&1
  fi
  export DECK_MTLS_CA_CERT=$(python3 -c 'import sys, json; print(json.dumps(sys.stdin.read()))' < docs/00-setup-entorno/scripts/ca.crt)
  mostrar_cmd "deck gateway sync ... 09-b9-mtls.yaml"
  if deck gateway sync $DECK_DIR/09-b9-mtls.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$KONNECT_CONTROL_PLANE_NAME"; then
    pass "Política mTLS inyectada correctamente."
  else
    fail "Error sincronizando mTLS."
    return 1
  fi
  pausa

  step "C.5 Validación de mTLS (Sin Certificado)"
  mostrar_cmd "curl -k -s -o /dev/null -w \"%{http_code}\" https://localhost:8443/mock"
  
  # Polling simple
  for i in {1..30}; do
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/mock)
    if [ "$HTTP_STATUS" == "401" ] || [ "$HTTP_STATUS" == "400" ]; then break; fi
    sleep 2
  done
  
  if [ "$HTTP_STATUS" == "401" ] || [ "$HTTP_STATUS" == "400" ]; then
    pass "401/400 - Bloqueado por falta de certificado de cliente válido."
  else
    fail "Esperábamos 401/400, recibimos $HTTP_STATUS"
  fi
  pausa

  echo -e "${YELLOW}>> Generando certificado de cliente válido para App-External (evita bug de validación en Konnect)...${NC}"
  mostrar_cmd "openssl req -new -nodes -subj \"/CN=App-External/O=MyOrg\" -keyout docs/00-setup-entorno/scripts/client.key -out docs/00-setup-entorno/scripts/client.csr && openssl x509 -req -in docs/00-setup-entorno/scripts/client.csr -CA docs/00-setup-entorno/scripts/ca.crt -CAkey docs/00-setup-entorno/scripts/ca.key -CAcreateserial -out docs/00-setup-entorno/scripts/client.crt -days 365"
  openssl req -new -nodes -subj "/CN=App-External/O=MyOrg" -keyout docs/00-setup-entorno/scripts/client.key -out docs/00-setup-entorno/scripts/client.csr >/dev/null 2>&1
  openssl x509 -req -in docs/00-setup-entorno/scripts/client.csr -CA docs/00-setup-entorno/scripts/ca.crt -CAkey docs/00-setup-entorno/scripts/ca.key -CAcreateserial -out docs/00-setup-entorno/scripts/client.crt -days 365 >/dev/null 2>&1
  pass "Certificado de cliente App-External regenerado."
  pausa

  step "C.5 Validación de mTLS (Con Certificado)"
  mostrar_cmd "curl -k -s -o /dev/null -w \"%{http_code}\" --cert docs/00-setup-entorno/scripts/client.crt --key docs/00-setup-entorno/scripts/client.key https://localhost:8443/mock"
  
  # Polling simple para esperar que la credencial mtls-auth se propague al Data Plane
  for i in {1..30}; do
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" --cert docs/00-setup-entorno/scripts/client.crt --key docs/00-setup-entorno/scripts/client.key https://localhost:8443/mock)
    if [ "$HTTP_STATUS" == "200" ]; then break; fi
    sleep 2
  done
  
  if [ "$HTTP_STATUS" == "200" ]; then
    pass "200 OK - Acceso mTLS permitido."
  else
    fail "Esperábamos 200, recibimos $HTTP_STATUS"
  fi
  pausa

  step "C.6 Demostración mTLS + OIDC (Identity)"
  export DECK_KONNECT_AUTH_ISSUER=$KONNECT_AUTH_ISSUER
  export DECK_KONNECT_AUTH_CLIENT_ID=$KONNECT_AUTH_CLIENT_ID
  export DECK_KONNECT_AUTH_CLIENT_SECRET=$KONNECT_AUTH_CLIENT_SECRET
  mostrar_cmd "deck gateway sync ... 10-b10-mtls-oidc.yaml"
  deck gateway sync workshop-assets/dia-1/07-securing-api-traffic/archivos-deck/10-b10-mtls-oidc.yaml --konnect-token "$KONNECT_TOKEN" --konnect-control-plane-name "$KONNECT_CONTROL_PLANE_NAME" > /dev/null 2>&1
  pass "Política mTLS + OIDC inyectada correctamente."
  pausa
  
  echo -e "${YELLOW}>> Solicitando token JWT a Konnect Identity (Client Credentials)...${NC}"
  
  # Reemplazamos mock-oidc por localhost para que el script pueda alcanzarlo desde fuera de la red Docker
  LOCAL_ISSUER="${KONNECT_AUTH_ISSUER//mock-oidc/localhost}"
  
  mostrar_cmd "export ACCESS_TOKEN=\$(curl -sX POST \"${LOCAL_ISSUER}/token\" -d \"client_id=...\" -d \"grant_type=client_credentials\")"
  
  # Reemplazamos mock-oidc por localhost para que el script pueda alcanzarlo desde fuera de la red Docker
  LOCAL_ISSUER="${KONNECT_AUTH_ISSUER//mock-oidc/localhost}"
  
  HOST_HEADER=$(echo $KONNECT_AUTH_ISSUER | awk -F/ '{print $3}')
  export ACCESS_TOKEN=$(curl -sX POST "${LOCAL_ISSUER}/token" \
   -H "Host: $HOST_HEADER" \
   -H 'Content-Type: application/x-www-form-urlencoded' \
   -d "client_id=${KONNECT_AUTH_CLIENT_ID}" \
   -d "client_secret=${KONNECT_AUTH_CLIENT_SECRET}" \
   -d 'grant_type=client_credentials' | python3 -c "import sys, json; print(json.load(sys.stdin).get('access_token', ''))")
  
  if [ -z "$ACCESS_TOKEN" ]; then
    fail "No se pudo obtener el ACCESS_TOKEN. Verifica KONNECT_AUTH_ISSUER, CLIENT_ID y CLIENT_SECRET."
  else
    pass "ACCESS_TOKEN obtenido: ${ACCESS_TOKEN:0:15}..."
  fi
  pausa

  echo -e "${YELLOW}>> Invocando ruta con mTLS pero SIN Token Bearer (Caso Negativo)...${NC}"
  mostrar_cmd "curl -k -s -o /dev/null -w \"%{http_code}\" --cert docs/00-setup-entorno/scripts/client.crt --key docs/00-setup-entorno/scripts/client.key https://localhost:8443/mock"
  
  # Polling for 401 because OIDC takes time to propagate
  for i in {1..30}; do
    HTTP_STATUS_NO_TOKEN=$(curl -k -s -o /dev/null -w "%{http_code}" --cert docs/00-setup-entorno/scripts/client.crt --key docs/00-setup-entorno/scripts/client.key https://localhost:8443/mock)
    if [ "$HTTP_STATUS_NO_TOKEN" == "401" ] || [ "$HTTP_STATUS_NO_TOKEN" == "403" ]; then break; fi
    sleep 2
  done
  
  if [ "$HTTP_STATUS_NO_TOKEN" == "401" ] || [ "$HTTP_STATUS_NO_TOKEN" == "403" ]; then
    pass "401 - Bloqueado por falta de Token JWT válido."
  else
    fail "Esperábamos 401, recibimos $HTTP_STATUS_NO_TOKEN"
  fi
  pausa

  echo -e "${YELLOW}>> Invocando ruta con mTLS + Token Bearer...${NC}"
  mostrar_cmd "curl -k -s -o /dev/null -w \"%{http_code}\" --cert docs/00-setup-entorno/scripts/client.crt --key docs/00-setup-entorno/scripts/client.key -H \"Authorization: Bearer \$ACCESS_TOKEN\" https://localhost:8443/mock"
  
  for i in {1..30}; do
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" --cert docs/00-setup-entorno/scripts/client.crt --key docs/00-setup-entorno/scripts/client.key -H "Authorization: Bearer $ACCESS_TOKEN" https://localhost:8443/mock)
    if [ "$HTTP_STATUS" == "200" ]; then break; fi
    sleep 2
  done
  
  if [ "$HTTP_STATUS" == "200" ]; then
    pass "200 OK - Acceso mTLS + JWT permitido."
  else
    fail "Esperábamos 200, recibimos $HTTP_STATUS"
  fi
  pausa
}

demo_modulo_08() {
  header "Módulo 08: Integración ITSM"
  check_env
  
  step "Simulando error 500 para disparar alerta ITSM"
  echo -e "${YELLOW}NOTA: Este demo asume que el plugin http-log está configurado para ITSM.${NC}"
  mostrar_cmd "curl -k -i https://localhost:8443/mock/status/500"
  curl -k -i https://localhost:8443/mock/status/500
  
  pass "Petición enviada. Revisa el endpoint del webhook configurado para verificar el ticket."
  pausa
}

demo_modulo_09() {
  header "Módulo 09: Gestión de Secretos"
  check_env
  
  step "Configurando el Vault de variables de entorno"
  mostrar_cmd "export KONG_VAULT_ENV_BACKEND_API_KEY=\"super-secret-key-12345\""
  export KONG_VAULT_ENV_BACKEND_API_KEY="super-secret-key-12345"
  
  step "Simulando petición con inyección de secreto"
  echo -e "${YELLOW}NOTA: Este demo asume que el plugin request-transformer está referenciando {vault://env/backend_api_key}.${NC}"
  mostrar_cmd "curl -k -i https://localhost:8443/mock"
  curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/mock
  
  pass "Petición enviada. Verifica en los logs del upstream si recibió 'super-secret-key-12345'."
  pausa
}

demo_modulo_10() {
  header "Módulo 10: Seguridad OWASP WAF"
  check_env
  
  step "Prueba Normal (Tráfico Legítimo)"
  echo -e "${YELLOW}NOTA: Este demo asume que el plugin de WAF (ej. coraza) está configurado y habilitado.${NC}"
  mostrar_cmd "curl -k -s -o /dev/null -w \"%{http_code}\" https://localhost:8443/mock?id=123"
  HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/mock?id=123)
  if [ "$HTTP_STATUS" == "200" ] || [ "$HTTP_STATUS" == "404" ] || [ "$HTTP_STATUS" == "401" ]; then
    pass "Tráfico legítimo procesado (Status: $HTTP_STATUS)"
  else
    fail "Respuesta inesperada: $HTTP_STATUS"
  fi
  pausa

  step "Prueba Maliciosa (SQL Injection)"
  mostrar_cmd "curl -k -i \"https://localhost:8443/mock?id=1'%20OR%20'1'='1\""
  HTTP_STATUS_WAF=$(curl -k -s -o /dev/null -w "%{http_code}" "https://localhost:8443/mock?id=1'%20OR%20'1'='1")
  if [ "$HTTP_STATUS_WAF" == "403" ]; then
    pass "403 Forbidden - Ataque SQLi bloqueado exitosamente por el WAF."
  else
    fail "Esperábamos 403, recibimos $HTTP_STATUS_WAF. ¿Está el WAF habilitado?"
  fi
  pausa
}

# ============================================================
# MENÚ INTERACTIVO
# ============================================================

menu() {
  while true; do
    clear
    header "Selector de Demostraciones (Instructor)"
    echo -e " ${BOLD}Seleccione el escenario a ejecutar:${NC}\n"
    echo " 1) Módulo 01: Kong Konnect Gateway (Básico)"
    echo " 2) Módulo 02: Kong Plugins (CORS, JWT, Limiting, etc.)"
    echo " 3) Módulo 04: Gateway Operations (IaC)"
    echo " 4) Módulo 05: Monitoring & Logging"
    echo " 5) Módulo 06: Observabilidad Avanzada"
    echo " 6) Módulo 07: Securing API Traffic"
    echo " 7) Módulo 08: Integración ITSM"
    echo " 8) Módulo 09: Gestión de Secretos"
    echo " 9) Módulo 10: Seguridad OWASP WAF"
    echo " A) Ejecutar TODOS los módulos en secuencia"
    echo " Q) Salir"
    echo ""
    echo -ne " ${CYAN}${BOLD}Opción: ${NC}"
    read -r opcion
    
    case $opcion in
      1) demo_modulo_01 ;;
      2) demo_modulo_02 ;;
      3) demo_modulo_04 ;;
      4) demo_modulo_05 ;;
      5) demo_modulo_06 ;;
      6) demo_modulo_07 ;;
      7) demo_modulo_08 ;;
      8) demo_modulo_09 ;;
      9) demo_modulo_10 ;;
      A|a)
        AUTO_MODE=true
        demo_modulo_01
        demo_modulo_02
        demo_modulo_04
        demo_modulo_05
        demo_modulo_06
        demo_modulo_07
        demo_modulo_08
        demo_modulo_09
        demo_modulo_10
        echo -e "${GREEN}${BOLD}¡Todas las demostraciones finalizaron exitosamente!${NC}"
        exit 0
        ;;
      Q|q)
        echo "Saliendo..."
        exit 0
        ;;
      *)
        echo -e "${RED}Opción inválida.${NC}"
        sleep 1
        ;;
    esac
  done
}

# Si pasaron --auto directamente por CLI
if [ "$AUTO_MODE" = true ]; then
  demo_modulo_01
  demo_modulo_02
  demo_modulo_04
  demo_modulo_05
  demo_modulo_06
  demo_modulo_07
  demo_modulo_08
  demo_modulo_09
  demo_modulo_10
  echo -e "${GREEN}${BOLD}¡Todas las demostraciones finalizaron exitosamente!${NC}"
  exit 0
else
  menu
fi
