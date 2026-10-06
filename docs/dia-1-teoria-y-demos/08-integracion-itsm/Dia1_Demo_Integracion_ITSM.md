# Integración ITSM (Alertas y Ticketing)

## Objetivo
Demostrar cómo Kong puede disparar la creación automática de incidentes en herramientas de ITSM (ServiceNow/Jira) de forma estándar e independiente de Datadog.

## Contenido Teórico
En arquitecturas distribuidas y orientadas a microservicios, la observabilidad y la respuesta a incidentes son críticas. Kong Gateway se sitúa en el borde de la red, lo que le permite tener una visibilidad completa del tráfico que fluye hacia las APIs. Aprovechando esta posición privilegiada, Kong puede detectar anomalías, como un incremento inusual en la tasa de errores (por ejemplo, códigos de estado HTTP 5xx), y notificar de inmediato a los sistemas de Gestión de Servicios de TI (ITSM) corporativos, como ServiceNow o Jira Service Management.

### Arquitectura del Flujo
1. **Detección en Kong:** Kong procesa el tráfico y, mediante el uso de plugins (como `http-log` o `pre-function`), evalúa el estado de las respuestas.
2. **Disparo de la Alerta:** Al detectar una condición de error (ej. un HTTP 500), el plugin configurado realiza una llamada asíncrona.
3. **Envío de Webhook:** Se envía un Webhook genérico con formato JSON hacia el endpoint del sistema ITSM.
4. **Creación del Ticket:** El sistema ITSM recibe el payload JSON, lo parsea y genera automáticamente un ticket de incidente, asignándolo al equipo correspondiente para su pronta resolución.

## Laboratorio Práctico

En este laboratorio, configuraremos el plugin `http-log` para que envíe un payload JSON simulando la creación de un ticket en un sistema ITSM ante un error 5xx.

### Paso 1: Configurar el plugin `http-log`
Vamos a añadir el plugin a nuestra ruta o servicio para enviar logs a un endpoint simulado (ejemplo: un webhook de [webhook.site](https://webhook.site)).

```yaml
plugins:
  - name: http-log
    config:
      http_endpoint: "https://webhook.site/tu-id-de-webhook-aqui"
      method: "POST"
      timeout: 10000
      keepalive: 60000
      flush_timeout: 2
      retry_count: 10
      custom_fields_by_lua:
        ticket_info: |
          return {
            title = "Alerta API: " .. kong.request.get_path(),
            description = "Se detectó un error " .. kong.response.get_status() .. " en el servicio.",
            priority = "High"
          }
```
*Nota: En un entorno real, puedes usar un plugin `serverless` (como `pre-function`) para tener un control más granular, ejecutando código Lua que solo envíe el webhook si el código de estado es `> 499` y estructurando el payload exactamente como lo requiera la API de ServiceNow o Jira.*

### Paso 2: Probar el Flujo
1. Genera un error forzado en tu API. Para este laboratorio, asumiendo que tienes una ruta apuntando a un servicio de pruebas como `httpbin.org`, podemos forzar un error HTTP 500 llamando al endpoint `/status/500`. Ejecuta este comando en tu terminal:

   ```bash
   curl -i http://localhost:8000/mock/status/500
   ```
   *(Asegúrate de reemplazar `/mock` por la ruta real que configuraste en Kong).*

2. Observa cómo Kong recibe el HTTP 500 del backend, captura el evento y ejecuta el plugin de forma automática.
3. Verifica en la consola del Webhook receptor (ej. webhook.site) que se ha recibido una petición POST. Dentro del cuerpo de la petición (JSON payload), podrás ver los datos del incidente listos para ser consumidos por el ITSM, similares a esto:

   ```json
   {
     "latencies": { "proxy": 140, "kong": 12, "request": 152 },
     "request": { "uri": "/mock/status/500", "method": "GET" },
     "response": { "status": 500 },
     "ticket_info": {
       "title": "Alerta API: /mock/status/500",
       "description": "Se detectó un error 500 en el servicio.",
       "priority": "High"
     }
   }
   ```
