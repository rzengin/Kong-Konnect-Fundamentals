# Requerimientos de Red - Workshop Kong Konnect

El siguiente documento detalla los requisitos de conectividad necesarios para la correcta ejecución del entorno del workshop, el cual incluye los Data Planes de Kong (Interno y Externo), el stack de observabilidad (OpenTelemetry Collector, OpenObserve y Arize Phoenix) y microservicios de prueba locales.

---

## 1. Reglas de Entrada (Inbound)
*Permitir que el tráfico llegue a la máquina/servidor donde se ejecuta el entorno del workshop.*

| Origen (Source) | Destino (Destination) | Puerto | Protocolo | Servicio / Proceso | Descripción (Justificación) |
| :--- | :--- | :---: | :---: | :--- | :--- |
| Red Corporativa / VPN | IP de la Máquina / Servidor | **8000** | TCP | Kong DP | Tráfico HTTP entrante hacia el API Gateway. |
| Red Corporativa / VPN | IP de la Máquina / Servidor | **8443** | TCP | Kong DP | Tráfico HTTPS entrante hacia el API Gateway. |
| Red Corporativa / VPN | IP de la Máquina / Servidor | **5080** | TCP | OpenObserve UI | Acceso a la interfaz web de observabilidad (trazas, métricas, logs, dashboards). |
| Red Corporativa / VPN | IP de la Máquina / Servidor | **6006** | TCP | Arize Phoenix UI | Acceso al visor de trazas orientado a LLM / IA. |
| Data Planes de los participantes | IP del Servidor del instructor | **4318** | TCP | OTel Collector (OTLP/HTTP) | (Solo en modo centralizado) Ingesta de trazas, logs y métricas enviadas por Kong. |
| Red Corporativa / VPN | IP de la Máquina / Servidor | **9081** | TCP | MockAPI Backend | (Opcional) Acceso directo al microservicio backend de pruebas. |
| Red Corporativa / VPN | IP de la Máquina / Servidor | **8090** | TCP | MockAPI Mock | (Opcional) Acceso directo al microservicio de vuelos. |

---

## 2. Reglas de Salida (Outbound) - CRÍTICAS
*Permitir que la máquina del workshop se comunique con Internet (SaaS y Repositorios).*

| Origen (Source) | Destino (Destination) | Puerto | Protocolo | Descripción (Justificación) |
| :--- | :--- | :---: | :---: | :--- |
| IP de la Máquina / Servidor | `*.konghq.com` | **443** | TCP (HTTPS) | **Esencial para Kong Konnect.** Los Data Planes locales necesitan conectarse al Control Plane en la nube para descargar configuración y enviar telemetría de forma continua. |
| IP de la Máquina / Servidor | `hub.docker.com` / `ghcr.io` | **443** | TCP (HTTPS) | Necesario para que Docker pueda descargar las imágenes de Kong, del stack de observabilidad (OTel Collector, OpenObserve, Phoenix) y microservicios. |
| IP de la Máquina / Servidor | `github.com` / `*.githubusercontent.com` | **443** | TCP (HTTPS) | Necesario para la clonación de repositorios del workshop o descarga de scripts/ejercicios. |

---

### Notas Adicionales
* **Servicios Internos:** Cuando el stack de observabilidad corre en la máquina de cada participante, la ingesta de OpenTelemetry (`4317`, `4318`) y el health check del Collector (`13133`, solo `127.0.0.1`) operan sobre la red privada virtual de Docker (`kong-workshop` / `otel-stack`). No es necesario exponerlos a nivel del firewall corporativo; solo hace falta abrir `4318` si el instructor usa un stack centralizado.
* **Ejecución en Codespaces/Local:** Si este entorno se ejecuta estrictamente en GitHub Codespaces o en la estación de trabajo personal de cada participante, las reglas *Inbound* solo deben garantizar que el entorno no bloquee los puertos de escucha locales. Las reglas *Outbound* siguen siendo obligatorias a nivel perimetral.
