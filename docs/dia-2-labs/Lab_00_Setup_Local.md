# Lab 00: Setup del Entorno
## Repaso de la Arquitectura Híbrida

Antes de montar nuestro laboratorio, recordemos brevemente la topología con la que vamos a interactuar a lo largo de este día práctico:

1. **Stack de Observabilidad (OpenTelemetry)**: Contenedores Docker livianos (OTel Collector, OpenObserve y Arize Phoenix, ~1.2 GB de RAM) que reciben y grafican las trazas, métricas y logs del Data Plane. Corren en la máquina de cada participante (o, opcionalmente, en un servidor centralizado del instructor que consolida la telemetría de todos los participantes).
2. **Local Server (Máquina del Participante)**: El entorno local de cada estudiante donde correrá el *Data Plane* de Kong Gateway (basado en NGINX/OpenResty) y las APIs simuladas (backends). Todo el tráfico ocurre localmente aquí.
3. **Kong Konnect (SaaS Control Plane)**: La consola de administración y base de datos maestra (Source of Truth) alojada en la nube de Kong, desde donde configuraremos las políticas. Se comunica con el *Data Plane* a través de un túnel seguro gRPC (mTLS).

```mermaid
flowchart LR
  classDef cp_style fill:#e0f2fe,stroke:#0284c7,stroke-width:2px,color:#0c4a6e,rx:10,ry:10;
  classDef dp_style fill:#ffedd5,stroke:#ea580c,stroke-width:2px,color:#7c2d12,rx:10,ry:10;
  classDef obs_style fill:#d1fae5,stroke:#059669,stroke-width:2px,color:#064e3b,rx:10,ry:10;
  classDef inner_cp fill:#bae6fd,stroke:#0284c7,stroke-width:1px,color:#0c4a6e;
  classDef inner_dp fill:#fed7aa,stroke:#ea580c,stroke-width:1px,color:#7c2d12;
  classDef inner_obs fill:#a7f3d0,stroke:#059669,stroke-width:1px,color:#064e3b;
  classDef client_style fill:#f8fafc,stroke:#64748b,stroke-width:2px,color:#0f172a,rx:20,ry:20;

  subgraph Nube ["OBSERVABILIDAD (Docker - otel-stack)"]
    direction TB
    subgraph Obs ["Local u opcionalmente centralizado por el instructor"]
      direction TB
      OTel["OTel Collector :4318"]:::inner_obs
      O2["OpenObserve UI :5080"]:::inner_obs
      PX["Phoenix UI :6006"]:::inner_obs
    end
  end
  Nube:::obs_style
  Obs:::obs_style

  subgraph Local ["LOCAL SERVER (Docker Host - Máquina del participante)"]
    direction TB
    Client(["Cliente (curl/Insomnia)"]):::client_style
    DP["Kong Data Plane :8000<br/>(NGINX/OpenResty & Worker Processes)"]:::inner_dp
    
    subgraph Backends ["Backend Microservices"]
      direction TB
      mock["httpbin-backend :9081"]:::inner_dp
    end
    Backends:::dp_style
  end
  Local:::dp_style

  subgraph Konnect ["KONG KONNECT (SaaS Control Plane)"]
    direction TB
    CP["Control Plane: TUPREFIJO_MockAPI<br/>(Management Console, Admin API, Policy Engine)"]:::inner_cp
    KA["Konnect Analytics"]:::inner_cp
  end
  Konnect:::cp_style

  %% Connections
  Client -->|"API Traffic"| DP
  DP -->|"Proxy Traffic"| mock
  CP <==>|"gRPC Tunnel (mTLS)<br/>Sincronización de config, políticas y certs"| DP
  DP ==>|"OTLP/HTTP"| OTel
  OTel --> O2
  OTel --> PX
  DP -.->|"Métricas de negocio"| KA
  
  %% Link Styles to match colors
  linkStyle 0 stroke:#10b981,stroke-width:2px;
  linkStyle 1 stroke:#f97316,stroke-width:2px;
  linkStyle 2 stroke:#0ea5e9,stroke-width:2px;
  linkStyle 3 stroke:#10b981,stroke-width:2px;
  linkStyle 4 stroke:#10b981,stroke-width:2px;
  linkStyle 5 stroke:#10b981,stroke-width:2px;
  linkStyle 6 stroke:#0ea5e9,stroke-width:2px,stroke-dasharray: 5 5;
```

---

## Preparación del Entorno

Todo lo que haremos durante los laboratorios asume que cuentas con este entorno base funcional. Hemos preparado dos opciones para que puedas levantar el entorno:

### Opción 1 (Recomendada): GitHub Codespaces
Si tu instructor te compartió el archivo `kong-workshop-assets.zip` para usar en el laboratorio:

1. Abre un **Codespace en blanco** (o en tu propio repositorio de GitHub).
2. **Arrastra y suelta** el archivo `kong-workshop-assets.zip` en la barra lateral izquierda (Explorador de archivos) de tu Codespace.
3. Abre una terminal y descomprime el archivo ejecutando:
  ```bash
  unzip kong-workshop-assets.zip
  ```
4. ¡Listo! Ya tienes las carpetas de assets y los scripts de setup en tu entorno. Salta directamente al **Paso 2**.


### Opción 2: Instalación Local
Si prefieres correr todo en tu propia máquina (Windows, Mac o Linux), necesitas tener instalados los siguientes prerrequisitos:

- **Docker / Docker Compose**

- **decK** (versión `1.65.1` o superior)
- **cURL**

- **Git**

> **Nota:** Puedes ver las instrucciones detalladas por sistema operativo en [Prerrequisitos Workshop](../00-setup-entorno/Prerequisitos_Workshop_Kong_Konnect_Instalacion.md).

Para usuarios de Mac/Linux, también puedes ejecutar nuestro script automatizado que instala las herramientas CLI (como `decK`):
```bash
cd ../../00-setup-entorno
./scripts/install_prereqs.sh
```

### Paso 2: Inicializar Variables y Levantar Contenedores
1. **Credenciales**: Necesitarás un Personal Access Token (`kpat_...`) de Kong Konnect. Pídeselo a tu instructor.
2. Configura las variables en tu terminal:

**En Mac/Linux (Bash):**
```bash
export KONNECT_TOKEN="kpat_xxxxx"
export DEMO_PREFIX="tu_nombre_o_iniciales"
```
**En Windows (CMD):**
```cmd
set KONNECT_TOKEN=kpat_xxxxx
set DEMO_PREFIX=tu_nombre_o_iniciales
```

3. Ejecuta el script de setup que levantará los mock backends y el Data Plane:

**En Mac/Linux (Bash):**
```bash
cd ../../00-setup-entorno
./scripts/setup.sh
```
**En Windows (CMD):**
```cmd
cd ..\..\00-setup-entorno
scripts\setup.bat
```

### Paso 3: Validación
Si todo fue exitoso, verás un mensaje verde indicando que el entorno está listo. 

1. **Validar contenedores:** Ejecuta `docker ps` para confirmar que tienes corriendo los siguientes contenedores:
  - `kong-dp` (El API Gateway local)
  - `httpbin-backend` (Nuestra API de servicios mockeada)
  - `mock-oidc` (Identity Provider mockeado para prácticas avanzadas)
  - `opa` (Motor de Open Policy Agent para demostraciones de Zero Trust)
  - `kafka` (Apache Kafka para pruebas de Event Gateway)

2. **Validar el Backend (httpbin):**
  Envía una petición directa al backend mockeado para verificar que esté escuchando.
  ```bash
  curl -s -i http://localhost:9081/anything/ping
  ```
  **Resultado esperado:** `200 OK` con un payload en formato JSON.

3. **Validar Kong Data Plane y Sincronización:**
  Verifica que el Data Plane local esté vivo y haya descargado exitosamente la configuración desde el Control Plane. Para ello, enviaremos una petición a la ruta `/healthcheck` (que fue creada automáticamente por el script de Terraform).
  ```bash
  curl -k -i https://localhost:8443/healthcheck
  ```
  **Resultado esperado:** `200 OK` y un mensaje indicando: `"Kong Gateway is Alive! Control Plane Sync is working."`. Esto confirma que tu Data Plane tiene conectividad de salida hacia Konnect.

---
¡Excelente! Tienes tu infraestructura local funcionando y enlazada al Control Plane en la nube. Estás listo para comenzar con los laboratorios.
