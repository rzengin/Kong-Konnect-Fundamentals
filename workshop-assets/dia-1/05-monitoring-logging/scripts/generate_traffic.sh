#!/bin/bash

# ==============================================================================
# Generador de Tráfico para Observabilidad
# Simula peticiones reales a Kong Gateway para popular los Dashboards de Konnect
# ==============================================================================

echo "=========================================================="
echo "🚀 Iniciando inyección de tráfico hacia Kong Gateway..."
echo "=========================================================="

echo "[1/4] Generando tráfico exitoso (200 OK) a /mock (External DP)..."
for i in {1..50}; do
  curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8000/mock &
done
wait

echo "[2/4] Generando errores de cliente (401 Unauthorized) a /customers (Internal DP)..."
# Asumimos que /customers puede requerir key-auth dependiendo del estado del lab, 
# forzaremos algunas llamadas sin api-key o con api-key inválida.
for i in {1..20}; do
  curl -s -o /dev/null -w "%{http_code}\n" http://localhost:18000/customers -H "apikey: invalid_key" &
done
wait

echo "[3/4] Generando tráfico de éxito (200 OK) a /routes (External DP)..."
for i in {1..30}; do
  curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8000/routes &
done
wait

echo "[4/4] Simulando posibles errores de backend (404 Not Found) a endpoints inexistentes..."
for i in {1..15}; do
  curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8000/non-existent-api &
done
wait

echo "=========================================================="
echo "✅ Inyección de tráfico completada."
echo "Puedes ir a la UI de Konnect Analytics para visualizar los resultados."
echo "=========================================================="
