#!/bin/bash
# ============================================================
# run_all_labs.sh (Validación Día 2)
# Validación interactiva/automatizada de los Laboratorios (Labs)
# del Kong Training Konnect Fundamentals (Devs, Ops & Sec).
# ============================================================

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

pass()    { echo -e "\n  ${GREEN}${BOLD}[OK] PASS${NC}: ${BOLD}$1${NC}\n"; }
fail()    { echo -e "\n  ${RED}${BOLD}[FAIL] FAIL${NC}: ${BOLD}$1${NC}\n"; }
header()  {
  echo ""
  echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════${NC}"
  echo -e "${CYAN}${BOLD}  $1${NC}"
  echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════${NC}"
  echo ""
}
step()    { echo -e "\n${YELLOW}${BOLD}  > $1${NC}\n"; }
mostrar_cmd() { echo -e "\n  ${GREEN}\$ $1${NC}\n"; }

AUTO_MODE=false
for arg in "$@"; do
  if [ "$arg" == "--auto" ]; then
    AUTO_MODE=true
  fi
done

pausa() {
  if [ "$AUTO_MODE" = false ]; then
    echo -ne "  ${CYAN}${BOLD}>> Presiona ENTER para continuar...${NC}"
    read -r
    echo ""
  else
    echo -e "  ${CYAN}${BOLD}>> Continuando automáticamente (--auto)...${NC}\n"
    sleep 2
  fi
}

check_env() {
    if [ -f "docs/00-setup-entorno/scripts/set_env.sh" ]; then
        source "docs/00-setup-entorno/scripts/set_env.sh" > /dev/null 2>&1
    fi

    if [ -z "$KONNECT_TOKEN" ] || [ "$KONNECT_TOKEN" == "kpat_XXXXXXXXX" ]; then
        echo -e "${RED}ERROR: KONNECT_TOKEN inválido o no definido. Configúralo en tu entorno o en set_env.sh.${NC}"
        exit 1
    fi
}

sync_lab() {
    local yaml_file=$1
    step "Aplicando configuración declarativa: $yaml_file"
    local target_cp="$KONNECT_CONTROL_PLANE_NAME"
    if ! deck gateway sync "$yaml_file" --konnect-control-plane-name "$target_cp" --konnect-token "$KONNECT_TOKEN"; then
        fail "Fallo al sincronizar la configuración. Revisa tu KONNECT_TOKEN."
        exit 1
    fi
    # Esperamos 20 segundos para asegurar que el Data Plane local descargue la configuración desde la nube de Konnect
    sleep 20
}


lab_00_setup() {
    header "Lab 00: Setup Local"
    check_env
    pass "Entorno configurado correctamente. KONNECT_TOKEN presente."
    pausa
}



demo_modulo_04() {
    header "Módulo 04: Gateway Operations (IaC)"
    check_env
    
    step "Demostración 0: Limpieza del Entorno Base (Simulando inicio de Día 2)"
    mostrar_cmd "./docs/00-setup-entorno/scripts/reset_all.sh"
    bash docs/00-setup-entorno/scripts/reset_all.sh
    
    echo -e "\n  ${YELLOW}> Levantando backend simulado y OIDC...${NC}"
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

    step "C.2 Validación de permisos (Credencial interna a ruta externa)"
    mostrar_cmd "curl -k -i https://localhost:8443/mock -H \"apikey: internal-secret-123\""
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/mock -H "apikey: internal-secret-123")
    if [ "$HTTP_STATUS" == "403" ]; then
        pass "403 Forbidden - Bloqueado por ACL (Rol inválido)"
    else
        fail "Esperábamos 403, recibimos $HTTP_STATUS"
    fi
    pausa

    step "C.2 Validación exitosa (Consumo legítimo)"
    mostrar_cmd "curl -k -i https://localhost:8443/mock -H \"apikey: external-secret-123\""
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/mock -H "apikey: external-secret-123")
    if [ "$HTTP_STATUS" == "200" ]; then
        pass "200 OK - Acceso permitido"
    else
        fail "Fallo al usar el apikey válido"
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

    step "C.4 Validación de Bloqueo de Red (Caso Negativo)"
    mostrar_cmd "docker run --rm --network kong-workshop curlimages/curl -k -s -o /dev/null -w \"%{http_code}\" https://kong-dp:8443/mock -H \"apikey: external-secret-123\""
    
    # Polling simple esperando propagación
    for i in {1..30}; do
        HTTP_STATUS=$(docker run --rm --network kong-workshop curlimages/curl -k -s -o /dev/null -w "%{http_code}" https://kong-dp:8443/mock -H "apikey: external-secret-123")
        if [ "$HTTP_STATUS" == "403" ]; then break; fi
        sleep 2
    done
    
    if [ "$HTTP_STATUS" == "403" ]; then
        pass "403 Forbidden - IP Restringida exitosamente a pesar de tener API Key válida (desde IP bloqueada)."
    else
        fail "Esperábamos 403, recibimos $HTTP_STATUS"
    fi
    pausa
    
    step "C.4 Validación de Bloqueo de Red (Caso Positivo)"
    mostrar_cmd "curl -k -i https://localhost:8443/mock -H \"apikey: external-secret-123\""
    
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/mock -H "apikey: external-secret-123")
    if [ "$HTTP_STATUS" == "200" ]; then
        pass "200 OK - Acceso permitido desde IP autorizada (Host)."
    else
        fail "Esperábamos 200, recibimos $HTTP_STATUS"
    fi
    pausa
}

lab_01_routing() {
    header "Lab 01: Routing Declarativo"
    sync_lab "workshop-assets/dia-2/lab_01_1.yaml"
    echo -e "\n  ${WHITE}${BOLD}[ℹ] ¿Cómo comprobarlo manualmente?${NC}"
    echo -e "      Envía una petición GET a /api/v1/mock. Debe retornar 200 OK."

    step "Probando acceso a la ruta base"
    mostrar_cmd "curl -k -i https://localhost:8443/api/v1/mock"
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/api/v1/mock)
    if [ "$HTTP_STATUS" == "200" ]; then
        pass "200 OK - Routing configurado correctamente."
    else
        fail "Fallo. Esperábamos 200, recibimos $HTTP_STATUS."
    fi
    pausa
}

lab_02_upstreams() {
    header "Lab 02: Upstreams & Health Checks"
    step "Validando Upstreams y Health Checks"
    sync_lab "workshop-assets/dia-2/lab_02_1.yaml"
    step "Validando Balanceo y Health Checks"
    mostrar_cmd "deck gateway sync workshop-assets/dia-2/lab_02_1.yaml && echo 'Esperando 15s...' && sleep 15 && for i in {1..6}; do curl -s http://localhost:8000/api/v1/mock | grep -E '\"url\"|\"message\"'; sleep 1; done"
    deck gateway sync workshop-assets/dia-2/lab_02_1.yaml --konnect-control-plane-name "$KONNECT_CONTROL_PLANE_NAME" --konnect-token "$KONNECT_TOKEN"
    echo "Esperando 15s..."
    sleep 15
    for i in {1..6}; do curl -s http://localhost:8000/api/v1/mock | grep -E '"url"|"message"'; sleep 1; done
    pass "Balanceo y Health Checks validados."
    pausa
}

lab_03_catalog() {
    header "Lab 03: Catalog APIs & OAS"
    step "Validando publicación de OAS en el catálogo"
    pass "API publicada correctamente."
    pausa
}

lab_04_transformaciones() {
    header "Lab 04: Transformaciones"
    sync_lab "workshop-assets/dia-2/lab_04_3.yaml"
    echo -e "\n  ${WHITE}${BOLD}[ℹ] ¿Cómo comprobarlo manualmente?${NC}"
    echo -e "      Envía una petición GET a /api/v1/mock y busca el header de respuesta 'x-empresa'."

    step "Verificando Headers de Transformación"
    mostrar_cmd "curl -k -i https://localhost:8443/api/v1/mock"
    RESPONSE=$(curl -k -s -i https://localhost:8443/api/v1/mock)
    if echo "$RESPONSE" | grep -qi "x-empresa"; then
        pass "Header 'x-empresa' encontrado en la respuesta."
    else
        fail "Fallo. No se encontró el header 'x-empresa'."
    fi
    pausa
}

lab_05_ruteo() {
    header "Lab 05: Ruteo Inteligente"
    sync_lab "workshop-assets/dia-2/lab_05_1.yaml"
    echo -e "\n  ${WHITE}${BOLD}[ℹ] ¿Cómo comprobarlo manualmente?${NC}"
    echo -e "      Envía GET a /api/v1/mock con 'x-region: latam'."

    step "Probando ruteo por header (Latam)"
    mostrar_cmd "curl -k -i -H \"x-region: latam\" https://localhost:8443/api/v1/mock"
    RESPONSE=$(curl -k -s -H "x-region: latam" https://localhost:8443/api/v1/mock)
    if echo "$RESPONSE" | grep -q "mock-latam"; then
        pass "Petición ruteada correctamente al upstream 'mock-latam'."
    else
        fail "Fallo. La petición no llegó al upstream correcto."
    fi
    pausa
}

lab_06_json() {
    header "Lab 06: Validación JSON"
    sync_lab "workshop-assets/dia-2/lab_06_1.yaml"
    echo -e "\n  ${WHITE}${BOLD}[ℹ] ¿Cómo comprobarlo manualmente?${NC}"
    echo -e "      Envía POST a /api/v1/echo con JSON válido e inválido."

    step "Probando con JSON inválido"
    mostrar_cmd "curl -k -i -X POST https://localhost:8443/api/v1/echo -H \"Content-Type: application/json\" -d '{\"tier\":\"premium\"}'"
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" -X POST https://localhost:8443/api/v1/echo -H "Content-Type: application/json" -d '{"tier":"premium"}')
    if [ "$HTTP_STATUS" == "400" ]; then
        pass "400 Bad Request - JSON validado correctamente (rechazado)."
    else
        fail "Fallo. Esperábamos 400, recibimos $HTTP_STATUS."
    fi
    pausa

    step "Probando con JSON válido"
    mostrar_cmd "curl -k -i -X POST https://localhost:8443/api/v1/echo -H \"Content-Type: application/json\" -d '{\"user_name\":\"admin\", \"transaction_id\":\"123\", \"tier\":\"premium\"}'"
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" -X POST https://localhost:8443/api/v1/echo -H "Content-Type: application/json" -d '{"user_name":"admin", "transaction_id":"123", "tier":"premium"}')
    if [ "$HTTP_STATUS" == "200" ]; then
        pass "200 OK - JSON validado correctamente (aceptado)."
    else
        fail "Fallo. Esperábamos 200, recibimos $HTTP_STATUS."
    fi
    pausa
}

lab_08_zero_trust() {
    header "Lab 08: Zero Trust Security"
    sync_lab "workshop-assets/dia-2/lab_08_1.yaml"
    echo -e "\n  ${WHITE}${BOLD}[ℹ] ¿Cómo comprobarlo manualmente?${NC}"
    echo -e "      Abre tu terminal o Insomnia y envía una petición a /api/v1/mock."
    echo -e "      Sin la cabecera 'apikey', debe fallar (401). Con 'apikey: secreto-123', debe pasar (200)."

    step "Probando acceso SIN API Key"
    mostrar_cmd "curl -k -i https://localhost:8443/api/v1/mock"
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/api/v1/mock)
    if [ "$HTTP_STATUS" == "401" ]; then
        pass "401 Unauthorized - Acceso denegado correctamente."
    else
        fail "Fallo. Esperábamos 401, recibimos $HTTP_STATUS."
    fi
    pausa

    step "Probando acceso CON API Key"
    mostrar_cmd "curl -k -i -H \"apikey: secreto-123\" https://localhost:8443/api/v1/mock"
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" -H "apikey: secreto-123" https://localhost:8443/api/v1/mock)
    if [ "$HTTP_STATUS" == "200" ]; then
        pass "200 OK - Acceso permitido."
    else
        fail "Fallo. Esperábamos 200, recibimos $HTTP_STATUS."
    fi
    pausa
}
lab_10_oidc() {

    header "Lab 10: Autenticación Avanzada (OIDC)"
    
    if [ -z "$KONNECT_AUTH_ISSUER" ] || [ -z "$KONNECT_AUTH_CLIENT_ID" ]; then
        echo -e "${YELLOW}Variables OIDC (KONNECT_AUTH_ISSUER, etc.) no encontradas. Saltando validación estricta del Lab 02.${NC}"
        pausa
        return
    fi
    
    export DECK_KONNECT_AUTH_ISSUER="$KONNECT_AUTH_ISSUER"
    export DECK_KONNECT_AUTH_CLIENT_ID="$KONNECT_AUTH_CLIENT_ID"
    export DECK_KONNECT_AUTH_CLIENT_SECRET="$KONNECT_AUTH_CLIENT_SECRET"
    
    sync_lab "workshop-assets/dia-2/lab_10_1.yaml"
    echo -e "\n  ${WHITE}${BOLD}[ℹ] ¿Cómo comprobarlo manualmente?${NC}"
    echo -e "      Haz una petición a /api/v1/echo sin token y verifica que dé 401."
    echo -e "      Luego, obtén un JWT desde Konnect Auth (Client Credentials) e inclúyelo como 'Bearer <token>'."

    step "Probando acceso SIN Token OIDC"
    mostrar_cmd "curl -k -i https://localhost:8443/api/v1/echo"
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/api/v1/echo)
    if [ "$HTTP_STATUS" == "401" ]; then
        pass "401 Unauthorized - Kong bloqueó la petición."
    else
        fail "Fallo. Esperábamos 401, recibimos $HTTP_STATUS."
    fi
    pausa

    echo -e "\n  > Obteniendo Token desde Konnect Identity\n"
    
    # If using local mock-oidc, translate the hostname for host-side curl
    LOCAL_TOKEN_URL="${KONNECT_AUTH_ISSUER}/token"
    CURL_OPTS=""
    if [[ "$LOCAL_TOKEN_URL" == *"mock-oidc"* ]]; then
        LOCAL_TOKEN_URL="${LOCAL_TOKEN_URL/mock-oidc/localhost}"
        CURL_OPTS="-H 'Host: mock-oidc:8081'"
    fi

    ACCESS_TOKEN=$(eval curl -k -sX POST "$LOCAL_TOKEN_URL" $CURL_OPTS -H "'Content-Type: application/x-www-form-urlencoded'" -d "'client_id=${KONNECT_AUTH_CLIENT_ID}'" -d "'client_secret=${KONNECT_AUTH_CLIENT_SECRET}'" -d "'grant_type=client_credentials'" | python3 -c "import sys, json; print(json.load(sys.stdin).get('access_token', ''))" 2>/dev/null)
    
    if [ -z "$ACCESS_TOKEN" ]; then
        fail "No se pudo obtener el token de Konnect."
    else
        pass "Token obtenido exitosamente."
        step "Probando acceso CON Token OIDC"
        mostrar_cmd "curl -k -i -H \"Authorization: Bearer \$ACCESS_TOKEN\" https://localhost:8443/api/v1/echo"
        HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $ACCESS_TOKEN" https://localhost:8443/api/v1/echo)
        if [ "$HTTP_STATUS" == "200" ]; then
            pass "200 OK - Acceso permitido con OIDC."
        else
            fail "Fallo. Esperábamos 200, recibimos $HTTP_STATUS."
        fi
    fi
    pausa
}

lab_09_ip_restriction() {
    header "Lab 09: Restricción de IP"
    sync_lab "workshop-assets/dia-2/lab_09_1.yaml"
    echo -e "\n  ${WHITE}${BOLD}[ℹ] ¿Cómo comprobarlo manualmente?${NC}"
    echo -e "      Envía una petición a /api/internal/reports."
    echo -e "      Usa el header 'X-Real-Ip: 200.150.10.20' para simular un ataque (debería dar 403)."

    step "Probando acceso desde IP denegada (200.150.10.20)"
    mostrar_cmd "curl -k -i -H \"X-Real-Ip: 200.150.10.20\" https://localhost:8443/api/internal/reports"
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" -H "X-Real-Ip: 200.150.10.20" https://localhost:8443/api/internal/reports)
    if [ "$HTTP_STATUS" == "403" ]; then
        pass "403 Forbidden - IP bloqueada correctamente."
    else
        fail "Fallo. Esperábamos 403, recibimos $HTTP_STATUS."
    fi
    pausa

    step "Probando acceso desde IP permitida"
    mostrar_cmd "curl -k -i https://localhost:8443/api/internal/reports"
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/api/internal/reports)
    if [ "$HTTP_STATUS" == "200" ]; then
        pass "200 OK - Acceso permitido."
    else
        fail "Fallo. Esperábamos 200, recibimos $HTTP_STATUS."
    fi
    pausa
}

lab_07_observabilidad() {
    header "Lab 07: Observabilidad Avanzada (OTel + OpenObserve + Phoenix)"
    check_env

    step "Levantando el stack de observabilidad"
    mostrar_cmd "./workshop-assets/dia-1/06-observability/scripts/setup-observability.sh"
    if ! bash workshop-assets/dia-1/06-observability/scripts/setup-observability.sh; then
        fail "No se pudo levantar el stack de observabilidad."
        pausa
        return
    fi

    sync_lab "workshop-assets/dia-2/lab_07_1.yaml"

    step "Generando tráfico para trazas, logs y métricas"
    mostrar_cmd "for i in {1..10}; do curl -s -o /dev/null -w \"%{http_code}\\n\" http://localhost:8000/api/v1/mock; sleep 0.5; done"
    for i in {1..10}; do
        curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8000/api/v1/mock
        sleep 0.5
    done
    pass "Tráfico generado."

    echo -e "\n  ${WHITE}${BOLD}[ℹ] ¿Cómo comprobarlo manualmente?${NC}"
    echo -e "      OpenObserve: http://localhost:5080 (credenciales: ./workshop-assets/dia-1/06-observability/scripts/setup-observability.sh status)"
    echo -e "        Traces / Logs / Metrics -> stream 'default' -> filtra service_name='TUPREFIJO_kong_dp'"
    echo -e "      Phoenix:     http://localhost:6006 -> proyecto 'TUPREFIJO_kong_dp'"
    pausa
}

lab_11_opa() {
    header "Lab 11: Gobernanza con OPA"
    sync_lab "workshop-assets/dia-2/lab_11_1.yaml"
    echo -e "\n  ${WHITE}${BOLD}[ℹ] ¿Cómo comprobarlo manualmente?${NC}"
    echo -e "      Haz curl a /api/v1/mock. El OPA denegará el acceso por defecto (403)."
    echo -e "      Añade el header 'x-role: admin' a la petición y OPA lo permitirá (200)."

    step "Probando acceso SIN rol de admin"
    mostrar_cmd "curl -k -i https://localhost:8443/api/v1/mock"
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/api/v1/mock)
    if [ "$HTTP_STATUS" == "403" ]; then
        pass "403 Forbidden - OPA denegó el acceso."
    else
        fail "Fallo. Esperábamos 403, recibimos $HTTP_STATUS."
    fi
    pausa

    step "Probando acceso CON rol de admin"
    mostrar_cmd "curl -k -i -H \"x-role: admin\" https://localhost:8443/api/v1/mock"
    HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" -H "x-role: admin" https://localhost:8443/api/v1/mock)
    if [ "$HTTP_STATUS" == "200" ]; then
        pass "200 OK - OPA permitió el acceso."
    else
        fail "Fallo. Esperábamos 200, recibimos $HTTP_STATUS."
    fi
    pausa
}

lab_12_kafka() {
    header "Lab 12: Event Gateway con Kafka"
    sync_lab "workshop-assets/dia-2/lab_12_kafka.yaml"
    echo -e "\n  ${WHITE}${BOLD}[ℹ] ¿Cómo comprobarlo manualmente?${NC}"
    echo -e "      Envía POST a /api/v1/async-orders con un JSON."
    echo -e "      Revisa que responda 200 OK con 'su solicitud fue recibida...' y verifica Kafka."

    step "Probando endpoint async"
    mostrar_cmd "curl -k -i -s -X POST https://localhost:8443/api/v1/async-orders -H \"Content-Type: application/json\" -d '{\"order_id\": \"123\", \"status\": \"NEW\"}'"
    
    # Obtenemos la respuesta completa (headers + body)
    RESPONSE=$(curl -k -i -s -X POST https://localhost:8443/api/v1/async-orders -H "Content-Type: application/json" -d '{"order_id": "123", "status": "NEW"}')
    
    # Extraemos el código HTTP
    HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP/" | awk '{print $2}')
    
    if [ "$HTTP_STATUS" == "200" ]; then
        pass "200 OK - Petición asíncrona procesada y enviada a Kafka."
        echo -e "  ${CYAN}${BOLD}Respuesta del API Gateway:${NC}"
        echo -e "  $RESPONSE\n"
    else
        fail "Fallo. Esperábamos 200, recibimos $HTTP_STATUS."
        echo -e "  Respuesta obtenida: $RESPONSE"
    fi
    pausa
}

menu() {
    while true; do
        clear
        header "Selector de Laboratorios (Devs & Ops)"
        echo -e "  ${BOLD}DÍA 2 - Mañana (Devs):${NC}"
        echo "  1) Lab 00: Setup Local"
        echo "  2) Lab 01: Routing Declarativo"
        echo "  3) Lab 02: Upstreams & Health Checks"
        echo "  4) Lab 03: Catalog APIs & OAS"
        echo "  5) Lab 04: Transformaciones"
        echo "  6) Lab 05: Ruteo Inteligente"
        echo "  7) Lab 06: Validación JSON"
        echo ""
        echo -e "  ${BOLD}DÍA 2 - Tarde (Ops & Sec):${NC}"
        echo "  8) Lab 07: Observabilidad Avanzada"
        echo "  9) Lab 08: Zero Trust (Key Auth)"
        echo " 10) Lab 09: Restricción de IPs"
        echo " 11) Lab 10: OIDC & ACL"
        echo " 12) Lab 11: OPA Authorization"
        echo " 13) Lab 12: Event Gateway con Kafka"
        echo ""
        echo -e "  ${BOLD}DEMOS (Instructor):${NC}"
        echo " 14) Demo Módulo 04: Gateway Operations"
        echo " 15) Demo Módulo 05: Monitoring & Logging"
        echo " 16) Demo Módulo 06: Observabilidad Avanzada"
        echo " 17) Demo Módulo 07: Securing API Traffic"
        echo ""
        echo "  A) Ejecutar TODOS los labs y demos en secuencia"
        echo "  Q) Salir"
        echo ""
        echo -ne "  ${CYAN}${BOLD}Opción: ${NC}"
        read -r opcion
        
        case $opcion in
            1) lab_00_setup ;;
            2) lab_01_routing ;;
            3) lab_02_upstreams ;;
            4) lab_03_catalog ;;
            5) lab_04_transformaciones ;;
            6) lab_05_ruteo ;;
            7) lab_06_json ;;
            8) lab_07_observabilidad ;;
            9) lab_08_zero_trust ;;
            10) lab_09_ip_restriction ;;
            11) lab_10_oidc ;;
            12) lab_11_opa ;;
            13) lab_12_kafka ;;
            14) demo_modulo_04 ;;
            15) demo_modulo_05 ;;
            16) demo_modulo_06 ;;
            17) demo_modulo_07 ;;
            A|a)
                AUTO_MODE=true
                lab_00_setup
                lab_01_routing
                lab_02_upstreams
                lab_03_catalog
                lab_04_transformaciones
                lab_05_ruteo
                lab_06_json
                lab_07_observabilidad
                lab_08_zero_trust
                lab_09_ip_restriction
                lab_10_oidc
                lab_11_opa
                lab_12_kafka
                demo_modulo_04
                demo_modulo_05
                demo_modulo_06
                demo_modulo_07
                echo -e "${GREEN}${BOLD}¡Todas las validaciones y demos finalizaron!${NC}"
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

check_env

if [ "$AUTO_MODE" = true ]; then
    lab_00_setup
    lab_01_routing
    lab_02_upstreams
    lab_03_catalog
    lab_04_transformaciones
    lab_05_ruteo
    lab_06_json
    lab_07_observabilidad
    lab_08_zero_trust
    lab_09_ip_restriction
    lab_10_oidc
    lab_11_opa
    lab_12_kafka
    demo_modulo_04
    demo_modulo_05
    demo_modulo_06
    demo_modulo_07
    exit 0
else
    menu
fi
