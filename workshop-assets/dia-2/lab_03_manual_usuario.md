# Manual de Usuario - MockAPI

Bienvenido al manual de integración de **MockAPI**, tu servicio de pruebas de confianza.

## 🚀 Empezando

Para comenzar a interactuar con MockAPI, asegúrate de tener acceso autorizado a la red o contar con las credenciales necesarias (dependiendo de las políticas de seguridad activas en Kong).

## 📌 Endpoints Principales

Nuestra API expone tres recursos principales diseñados para probar las capacidades de ruteo y transformación:

1. `/mock` - Endpoint general para peticiones básicas. Retorna metadatos de la petición.
2. `/echo` - Endpoint especializado para pruebas de introspección (Echo Server).
3. `/customers` - Endpoint enfocado a operaciones de clientes B2B.

## 🛠 Ejemplos de Integración

Puedes utilizar `curl` para enviar peticiones a nuestra API.

**Llamada Básica (GET):**
```bash
curl -k -i https://<KONG_GATEWAY_IP>:8443/mock
```

**Pasando Parámetros (POST):**
```bash
curl -k -i -X POST https://<KONG_GATEWAY_IP>:8443/mock \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Kong", "rol":"API Gateway"}'
```

## 🐛 Soporte y Troubleshooting

Si recibes respuestas `401 Unauthorized` o `403 Forbidden`, es probable que tus credenciales falten o hayan expirado.
Si recibes `429 Too Many Requests`, has superado tu cuota de Rate Limiting permitida.

Para asistencia adicional, por favor contacta al equipo de Plataforma de APIs.
