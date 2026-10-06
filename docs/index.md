# Kong API Gateway & Konnect Workshop



Bienvenido al material oficial del Workshop de **Kong API Gateway & Konnect**. 
Este curso presencial de dos días está orientado a proporcionar formación práctica en API Gateway, GitOps, Seguridad y Observabilidad.

![Kong Konnect Overview](./public/konnect_unified_api_platform.png)

---

## Descripción y Objetivos

Todo el workshop utiliza un enfoque **GitOps** con gestión declarativa vía **decK**, automatización con **Terraform**, y backends simulados con Docker.

### Backend de Pruebas: httpbin
Como hilo conductor de nuestras prácticas y demostraciones, utilizaremos **httpbin** como nuestro backend de pruebas simulado. En nuestro entorno local, este servicio ya se encuentra pre-desplegado mediante Docker (en el contenedor `httpbin-backend`). `httpbin` es una herramienta genérica muy utilizada para probar peticiones HTTP; nos permite verificar de manera sencilla qué headers, métodos y cuerpos de mensajes están llegando efectivamente al backend luego de pasar por el API Gateway. 

Nuestro trabajo durante el workshop será exponer, asegurar y gestionar el tráfico hacia estas APIs de prueba utilizando Kong Konnect, permitiéndonos enfocarnos en el ruteo, las transformaciones y las políticas de seguridad sin depender de una lógica de negocio compleja en el backend.



### Día 1: Bloque Teórico — Fundamentos, Operaciones y Seguridad
**Teoría Integral de Kong Konnect**

- **Arquitectura Conceptual**: Entender la separación Control Plane (Konnect) y Data Plane (Kong Gateway basado en NGINX/OpenResty), y la comunicación vía túnel gRPC mTLS.
- **Developer Track**: Conceptos de Gateway Services, Routes, Plugins, Developer Portal y publicación de Catalog APIs.
- **Operations Track**: Gobierno declarativo con decK/Terraform, monitoreo de tráfico y observabilidad avanzada con OpenTelemetry (OpenObserve + Arize Phoenix).
- **Security Track**: Estrategias Zero Trust, OIDC, RBAC y control de acceso mediante OPA.

### Día 2: Bloque Práctico — Hands-On Labs y Desafío Final
**Laboratorios Guiados y Práctica**

- **Setup y Ruteo**: Inicialización del entorno local y despliegue declarativo de rutas.
- **Plugins y Portales**: Transformaciones de payload, ruteo inteligente y publicación de catálogos OAS.
- **Operaciones y Seguridad**: Despliegue de observabilidad local (OTel Collector + OpenObserve + Phoenix), aplicación de Key Auth, restricción de IPs y OIDC.
- **Event Gateway**: Integración asíncrona enviando mensajes a tópicos de Kafka (Event-Driven Architecture).

---

## Agenda Completa del Taller

El workshop está planificado en dos jornadas estructuradas de **08:00 a 17:00**:

### Día 1: Teórico y Demostraciones
| Horario | Bloque | Tema / Módulo |
|---------|--------|---------------|
| **08:00 - 08:30** | Mañana (Todos) | Bienvenida, Arquitectura y Setup Conceptual |
| **08:30 - 09:15** | Mañana (Dev) | Módulo 00: Arquitectura Conceptual y Setup Local |
| **09:15 - 10:15** | Mañana (Dev) | Módulo 01: Kong Konnect Gateway & Control Planes |
| **10:15 - 10:30** | - | *Coffee Break* |
| **10:30 - 12:00** | Mañana (Dev) | Módulo 02: Ecosistema de Kong Plugins |
| **12:00 - 13:00** | Mañana (Dev) | Módulo 03: Developer Portal, Customización y Onboarding |
| **13:00 - 14:15** | - | *Almuerzo (Devs se retiran)* |
| **14:15 - 15:15** | Tarde (Ops)  | Módulo 04: Gateway Operations & GitOps (decK / Terraform) |
| **15:15 - 15:45** | Tarde (Ops)  | Módulo 05: Monitoring y Logging (Konnect Analytics) |
| **15:45 - 16:00** | - | *Coffee Break* |
| **16:00 - 16:45** | Tarde (Ops)  | Módulo 06: Observabilidad Avanzada (OpenTelemetry / OpenObserve / Phoenix) |
| **16:45 - 17:30** | Tarde (Sec)  | Módulo 07: Securing API Traffic (Key Auth, ACL, OIDC, IP Restriction) |
| **17:30 - 17:45** | Tarde (Todos)| **Health Check de Entornos** (Preparación Día 2) |

### Día 2: Práctico — Hands-On Labs y Cierre
| Horario | Bloque | Laboratorio / Actividad Práctica |
|---------|--------|----------------------------------|
| **08:00 - 08:15** | Mañana (Todos) | Bienvenida al Día Práctico, credenciales y repaso GitOps |
| **08:15 - 09:00** | Mañana (Dev) | **Lab:** Setup del Entorno Local |
| **09:00 - 09:50** | Mañana (Dev) | **Lab:** Routing Declarativo + Upstreams & Health Checks |
| **09:50 - 10:05** | - | *Coffee Break* |
| **10:05 - 11:20** | Mañana (Dev) | **Lab:** Catalog APIs & OAS + Transformaciones |
| **11:20 - 12:00** | Mañana (Dev) | **Labs Avanzados:** Ruteo Inteligente y Validación JSON |
| **12:00 - 13:00** | - | *Almuerzo (Devs se retiran / Ingresa Ops)* |
| **13:00 - 13:15** | Tarde (Todos)| Bienvenida y sincronización de entornos (Ingresantes de la tarde) |
| **13:15 - 14:15** | Tarde (Ops) | **Lab:** Observabilidad Distribuida con OTel, OpenObserve y Phoenix |
| **14:15 - 15:25** | Tarde (Sec) | **Lab:** Zero Trust Key Auth + OIDC & ACL |
| **15:25 - 15:40** | - | *Coffee Break* |
| **15:40 - 16:25** | Tarde (Sec) | **Lab:** Restricción de IPs + OPA Authorization |
| **16:25 - 17:00** | Tarde (Todos)| Cierre del taller, resolución de dudas y próximos pasos |
