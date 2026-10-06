KONG

Prerrequisitos de Instalación

Workshop Kong Konnect

Guía simple para preparar la estación de trabajo del alumno

| Campo | Detalle |
|---|---|
| Proveedor | KONG |
| Plataforma | Kong Konnect - arquitectura híbrida con Control Plane SaaS y entornos locales de laboratorio |
| Objetivo | Indicar qué debe instalar cada alumno, qué debe estar configurado en Konnect y qué conectividad debe tener desde su estación de trabajo. |
| Versión | 0.4 |
| Fecha | 26-ago-2026 |

Importante: no incluir tokens reales de Konnect en documentos, correos,
tickets o repositorios. Cada alumno debe usar un PAT propio o un token
temporal entregado por el instructor.

1\. Objetivo de este documento

Este documento resume, de forma práctica, lo que cada alumno debe tener
listo antes del workshop de Kong Konnect. El foco es preparar la laptop
para ejecutar ejercicios locales, administrar configuración declarativa
con decK, importar colecciones en Insomnia, levantar servicios de
laboratorio con Docker y validar conexión contra la instancia de Kong
Konnect asignada.

El documento no reemplaza la guía del laboratorio. Su propósito es
servir como checklist previo para evitar que el tiempo del workshop se
consuma instalando herramientas básicas o resolviendo bloqueos de red.

# Elige tu camino: Codespaces (A) o instalación local (B)

!!! tip "Camino A — GitHub Codespaces (recomendado)"
    Un entorno Linux en la nube, listo en ~5 minutos, con **Docker, decK, kongctl, inso, Terraform, Node.js, Python y jq** ya instalados. Solo necesitas un navegador y una cuenta de GitHub con acceso al repositorio del curso. Evita las restricciones típicas de laptops corporativas (Docker Desktop sin licencia o bloqueado, Windows sin WSL2, proxies, permisos de administrador).

    [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/rzengin/Kong-Konnect-Fundamentals?quickstart=1)

    1. Pulsa el botón (o en GitHub: **Code → Codespaces → Create codespace on main**). Elige la máquina de **4 núcleos / 16 GB** (es la que exige el devcontainer y la necesaria para el Día 4 con Ollama).
    2. Espera a que termine la creación: el contenedor ejecuta `docs/00-setup-entorno/scripts/install_prereqs.sh` automáticamente.
    3. Define tus variables (mejor como [secretos de Codespaces](https://github.com/settings/codespaces) `KONNECT_TOKEN` y `DEMO_PREFIX`, o en la terminal):
       ```bash
       export KONNECT_TOKEN="kpat_..."   # entregado por el instructor
       export DEMO_PREFIX="tu_nombre"
       ```
    4. Los puertos del laboratorio se reenvían solos (pestaña **Ports**): 8000/8443 proxy de Kong, 8001 Admin API, 5080 OpenObserve, 6006 Phoenix, 4318 OTLP y, para los Días 3–4, 8010 proxy del AI Gateway, 8110 status del Data Plane y 8089 WireMock. Donde las guías digan `http://localhost:<puerto>`, usa `curl` desde la terminal del Codespace o abre la URL reenviada desde la pestaña **Ports**.

    Con el camino A puedes saltar directamente a la [sección 4](#4-configuracion-requerida-en-kong-konnect) (configuración en Konnect); las secciones 2–3 solo aplican a la instalación local.

!!! note "Camino B — Instalación local"
    Si prefieres trabajar en tu laptop (o no tienes acceso a Codespaces), instala las herramientas siguiendo las secciones 2 y 3. En macOS y Linux el script `docs/00-setup-entorno/scripts/install_prereqs.sh` automatiza la mayor parte.

# 2. Checklist mínimo antes del workshop

| **Categoría** | **Requisito (Versión Mínima)** | **Uso en los ejercicios** |
|---|---|---|
| Sistema operativo | macOS, Linux o Windows (CMD) | Ejecutar CLI, Docker, scripts y pruebas locales. |
| Docker | Docker Desktop o Docker Engine (v20.10+) con Docker Compose (v2.x) | Levantar Kong Data Plane local, mocks, Keycloak, WireMock, Prism y stack de observabilidad. |
| Git | Cliente Git instalado (v2.20+) | Clonar o recibir el repositorio de assets del workshop. |
| curl | CLI curl disponible (v7.0+) | Probar APIs, Konnect, mocks y endpoints locales. |
| jq | Procesador JSON de línea de comandos (v1.6+) | Leer respuestas JSON de APIs y scripts. |
| decK | decK CLI (v1.65+) o versión indicada por el instructor | Sincronizar servicios, rutas, plugins y consumers contra Konnect. |
| kongctl | kongctl CLI (v1.20.1+) | Días 3–4: configuración declarativa del AI Gateway en Konnect (ver [sección 8](#8-dias-3-y-4-ai-gateway-requisitos-adicionales)). |
| Insomnia | Aplicación desktop Insomnia (v8.0+) | Importar colecciones, OpenAPI y ejecutar pruebas manuales o Runner. |
| Terraform | Terraform CLI (v1.5+), requerido para ejercicios APIOps/Portal/Catalog | Gestionar recursos de plataforma cuando el laboratorio lo incluya. |
| Node.js / npm / inso | Node.js LTS (v18+) y, si aplica, Insomnia CLI | Ejecutar pruebas por terminal con inso y utilitarios de apoyo. |
| Editor | VS Code u otro editor de texto | Editar YAML, OpenAPI, .env y scripts. |

# 3. Instalación por sistema operativo

### 3.1 Windows (CMD)

Si utilizas Windows y vas a ejecutar el workshop desde la línea de comandos `cmd.exe`:

- **Docker:** Instala [Docker Desktop para Windows](https://docs.docker.com/desktop/setup/install/windows-install/).
- **Git y curl:** Usualmente vienen incluidos en Windows 10/11. Puedes instalar Git descargándolo desde [git-scm.com](https://git-scm.com/).
- **decK CLI:** Puedes instalarlo vía `winget` o descargando el binario:
  ```cmd
  winget install Kong.decK
  ```
- **jq:** Puedes instalarlo vía `winget`:
  ```cmd
  winget install jqlang.jq
  ```
- **Terraform:**
  ```cmd
  winget install Hashicorp.Terraform
  ```

### 3.2 macOS (Intel o Apple Silicon)

Las siguientes instrucciones son prácticas. Si KONG utiliza
empaquetadores corporativos, Intune, SCCM, Jamf, repositorios internos o
restricciones de software, usar el mecanismo corporativo equivalente y
luego ejecutar las validaciones de la sección 6.

## 3.1 macOS

Opción recomendada: Homebrew para herramientas CLI y
descarga/instalación de Docker Desktop e Insomnia. Abrir Terminal y
ejecutar:

```bash
# 1) Instalar herramientas base de Apple si no existen
xcode-select --install

# 2) Instalar Homebrew si no está instalado
/bin/bash -c "$(curl -fsSL
https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3) Actualizar Homebrew
brew update

# 4) Instalar herramientas CLI
brew install git curl python@3.12 node kong/deck/deck
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# 5) Instalar aplicaciones desktop
brew install --cask docker insomnia visual-studio-code
```

Después de instalar Docker Desktop:

1. Abrir Docker Desktop desde Applications.

2. Aceptar los términos de uso de Docker Desktop según la política de
  KONG.

3. En Settings \> Resources asignar al menos 4 GB de memoria si la
  laptop lo permite. El stack de observabilidad (Módulo 06 / Lab 07:
  OTel Collector + OpenObserve + Arize Phoenix) consume ~1.2 GB de ese
  total; ya no se requieren los ~4 GB adicionales de la plataforma anterior.

4. Esperar a que Docker indique estado Running.

Validación rápida en macOS:

```bash
git --version
curl --version

python3 --version
node -v
npm -v
docker version
docker compose version
deck version
terraform version
```



## 3.3 Linux

Las instrucciones siguientes cubren Ubuntu/Debian. Para Fedora/RHEL,
usar dnf y paquetes rpm equivalentes. En Linux se puede usar Docker
Desktop o Docker Engine; para el workshop, Docker Engine con Docker
Compose suele ser suficiente.

### 3.3.1 Ubuntu/Debian - herramientas base

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release git 
unzip python3 python3-pip
```

### 3.3.2 Ubuntu/Debian - Docker Engine y Docker Compose

```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg
--dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture)
signed-by=/etc/apt/keyrings/docker.gpg]
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo
${UBUNTU_CODENAME:-$VERSION_CODENAME}) stable" | sudo tee
/etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER

# Cerrar sesión y volver a entrar para que aplique el grupo docker.
```

### 3.3.3 Ubuntu/Debian - Terraform

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor
-o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb
[signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg]
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo
tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update
sudo apt-get install -y terraform
```

### 3.3.4 Ubuntu/Debian - Node.js LTS

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
node -v
npm -v
```

### 3.3.5 Ubuntu/Debian - decK

```bash
DECK_VERSION="1.59.1"
curl -sL
"https://github.com/Kong/deck/releases/download/v${DECK_VERSION}/deck_${DECK_VERSION}_linux_amd64.tar.gz"
-o deck.tar.gz
tar -xf deck.tar.gz
sudo mv deck /usr/local/bin/deck
rm deck.tar.gz

deck version
```

### 3.3.6 Ubuntu/Debian - Insomnia

Descargar el paquete Linux desde el sitio oficial de Insomnia. Si se
descarga un .deb, instalarlo así desde la carpeta Downloads:

```bash
cd ~/Downloads
sudo apt install ./Insomnia\*.deb
```

Validación rápida en Linux:

```bash
git --version
curl --version

python3 --version
node -v
npm -v
docker version
docker compose version
deck version
terraform version
```

# 4. Configuración requerida en Kong Konnect

Cada alumno debe tener acceso a la organización de Konnect usada en el
workshop y al Control Plane asignado para los ejercicios. El instructor
o administrador de la plataforma debe validar estos puntos antes de
iniciar.

| **Elemento** | **Debe estar listo** | **Validación esperada** |
|---|---|---|
| Cuenta Konnect | Usuario invitado y con acceso a la organización del workshop. | El alumno puede iniciar sesión en Konnect. |
| Control Plane | Control Plane disponible para los ejercicios. Para esta guía: `tu_nombre_MockAPI` | El alumno puede ver el Control Plane en Konnect. |
| Permisos | Permisos suficientes para leer Data Plane Nodes y administrar servicios, rutas, plugins, consumers y credenciales según el laboratorio. | El alumno puede ejecutar deck gateway ping y sincronizar configuración si el ejercicio lo requiere. |
| Personal Access Token | PAT personal o token temporal provisto por el instructor. No debe compartirse ni documentarse. | El token permite conexión de decK a Konnect. |
| Data Plane local | Assets, certificados o docker-compose provistos por el instructor si el alumno debe levantar su propio Data Plane. | En Konnect, el Data Plane debe aparecer conectado y, cuando aplique, en estado In Sync. |

## 4.1 Variables de entorno

Usar los valores definidos para el workshop. El token real debe ser
introducido por cada alumno en su propia estación de trabajo.

```bash
# macOS / Linux / Codespaces
export KONNECT_TOKEN="<PAT_PERSONAL_O_TOKEN_TEMPORAL>"
export DEMO_PREFIX="tu_nombre"
export KONNECT_CONTROL_PLANE_NAME="${DEMO_PREFIX}_MockAPI"
export CONTROL_PLANE_NAME="$KONNECT_CONTROL_PLANE_NAME"
export KONNECT_ADDR="https://us.api.konghq.com"
```

## 4.2 Archivo .deck.yaml

Si el repositorio del workshop incluye un script de setup, usar ese
script. Si se requiere crear el archivo manualmente, desde la carpeta
del laboratorio:

```bash
# macOS / Linux / Codespaces
cat > .deck.yaml <<EOF
konnect-token: "$KONNECT_TOKEN"
konnect-addr: "$KONNECT_ADDR"
konnect-control-plane-name: "$KONNECT_CONTROL_PLANE_NAME"
EOF

# Validar
deck gateway ping
```

# 5. Conectividad requerida desde la estación de trabajo

Antes del workshop, validar que la red corporativa, VPN, proxy,
antivirus y firewall local no bloqueen la comunicación necesaria. Si
KONG usa inspección TLS, puede ser necesario permitir excepciones para
los dominios de Konnect y repositorios de software.

| Destino / Puerto | Uso | Requisito |
|------------------|-----|-----------|
| `https://us.api.konghq.com:443` | API de Konnect usada por decK y scripts. | Salida HTTPS permitida desde la laptop. |
| Dominios runtime de Konnect / `*.konghq.com:443` | Conexión del Data Plane local con el Control Plane SaaS. | Salida TLS permitida; evitar ruptura por inspección TLS. |
| `github.com` / `releases.githubusercontent.com:443` | Descarga de decK, assets y dependencias. | Salida HTTPS permitida. |
| `registry-1.docker.io` / `auth.docker.io` / Docker Hub:443 | Descarga de imágenes Docker del laboratorio. | Salida HTTPS permitida; autenticarse si la red tiene rate limits. |
| `npmjs.org` / `nodejs.org` / `deb.nodesource.com:443` | Node.js, npm e inso CLI cuando aplique. | Salida HTTPS permitida. |
| `releases.hashicorp.com` / `apt.releases.hashicorp.com:443` | Instalación de Terraform. | Salida HTTPS permitida. |
| `github.com/Kong/terraform-provider-konnect:443` | Descarga del provider kong/konnect. | Salida HTTPS permitida. |
| `insomnia.rest` / GitHub releases:443 | Descarga de Insomnia. | Salida HTTPS permitida. |

## 5.1 Puertos locales que deben estar libres

Los ejercicios pueden levantar varios contenedores locales. Antes de
iniciar, cerrar servicios que estén usando estos puertos o solicitar al
instructor variables alternativas.

| Puerto local | Servicio típico | Uso en laboratorio |
|-------------|----------------|--------------------|
| 8000 | Kong Proxy | Entrada principal para probar APIs expuestas por Kong. |
| 8010 | Segundo Data Plane opcional / Proxy del AI Gateway | Día 2: ejercicio de clustering / escalabilidad. Días 3–4: proxy del AI Gateway (`AIGW_PROXY_PORT` si ambos coinciden). |
| 8110 | Status del Data Plane del AI Gateway | Health check del Data Plane 2.2 (Días 3–4). |
| 8089 | WireMock (AI Gateway) | Core bancario REST (→ MCP), agentes A2A y proveedor caído (Días 3–4). |
| 8080 | Prism Mock | Mock de API basado en OpenAPI. |
| 9081 | httpbin-backend | Backend echo para validar headers, body y transformaciones. |
| 8082 | WireMock | Mock de APIs de negocio. |
| 8083 | Keycloak | Servidor OIDC local para ejercicios de autenticación. |
| 8100 | Kong metrics | Endpoint local de métricas Prometheus. |
| 5080 | OpenObserve | UI de observabilidad: trazas, métricas, logs y dashboards (Módulo 06 / Lab 07). |
| 6006 | Arize Phoenix | UI de trazas orientada a LLM / IA (Módulo 06 / Lab 07). |
| 4317 / 4318 | OpenTelemetry Collector | Recepción OTLP gRPC / HTTP de trazas, métricas y logs. |
| 13133 | OpenTelemetry Collector | Health check (solo `127.0.0.1`). |
| 9092 | Kafka | Broker para pruebas de Event Gateway (Lab 12). |

# 6. Validación antes del workshop

Ejecutar esta validación al menos un día antes del workshop. Si falla
cualquier punto, levantarlo como bloqueo operativo.

## 6.1 Validar herramientas locales

```bash
git --version
curl --version

python3 --version || python --version
node -v
npm -v
docker version
docker compose version
deck version
terraform version
```

## 6.2 Validar Docker

```bash
docker run --rm hello-world
docker compose version
```

## 6.3 Validar conectividad con Konnect

```bash
curl -I https://us.api.konghq.com

deck gateway ping
```

## 6.4 Validar Data Plane local cuando esté levantado

```bash
curl -i http://localhost:8000/qualquer-rota
```
```bash
# Respuesta esperada si Kong está activo pero sin rutas:
# HTTP/1.1 404 Not Found
# {"message":"no Route matched with those values"}
```

# 7. Problemas comunes y corrección rápida

| **Síntoma** | **Causa probable** | **Acción sugerida** |
|---|---|---|
| docker: command not found | Docker no instalado o PATH no actualizado. | Abrir nueva terminal y verificar instalación. |
| Cannot connect to the Docker daemon | Docker Desktop no está iniciado o el usuario no pertenece al grupo docker en Linux. | Iniciar Docker Desktop. En Linux ejecutar `usermod -aG docker $USER` y reabrir sesión. |
| deck gateway ping falla con 401/403 | PAT inválido, expirado o sin permisos. | Regenerar PAT o validar permisos en Konnect. |
| deck gateway ping no resuelve DNS o timeout | Proxy, VPN, DNS o firewall bloquean salida a Konnect. | Validar salida HTTPS a us.api.konghq.com y dominios runtime de Konnect. |
| Puerto local ocupado | Otro proceso usa el puerto requerido. | Identificar proceso y liberar puerto, o pedir al instructor variable alternativa. |
| Docker no descarga imágenes | Bloqueo a Docker Hub, proxy no configurado o rate limit. | Configurar proxy corporativo en Docker Desktop o usar mirror corporativo. |
| Insomnia no importa colección | Archivo incorrecto o versión desactualizada. | Actualizar Insomnia y volver a importar el workspace entregado. |
| terraform init falla con error 403/timeout | Restricción de red o proxy impide descargar el provider. | Realizar instalación offline del provider (Ver Sección 7.1). |



# 8. Días 3 y 4 — AI Gateway (requisitos adicionales)

Los Días 3 y 4 usan **Kong AI Gateway 2.2** (Control Plane en Konnect + Data Plane `kong/kong-ai-gateway:2.2.0` en Docker) junto con Redis Stack, WireMock y **Ollama** con modelos open-weight pequeños (CPU, sin claves de pago). Además de lo anterior, cada participante necesita:

| **Requisito** | **Detalle** | **Validación** |
|---|---|---|
| kongctl | **v1.20.1 o superior** (la 1.16 no conoce las entidades de AI Gateway 2.1/2.2). Binarios en la release [v1.20.1](https://github.com/Kong/kongctl/releases/tag/v1.20.1); `install_prereqs.sh` lo instala o lo actualiza. | `kongctl version` |
| Docker | Al menos **8 GB de RAM** asignados a Docker (10–12 GB si además se levanta el stack de observabilidad del Lab IA 08). | `docker info` |
| Disco | **~6 GB libres**: imagen del Data Plane, Redis Stack, WireMock, Ollama y ~2,1 GB de modelos (`llama3.2:1b`, `qwen3:0.6b`, `nomic-embed-text`). | `docker system df` |
| jq, curl, openssl, python3 | Las mismas de los Días 1–2 (confirmar `jq`). | `jq --version && python3 --version` |
| Puertos libres | `8010` (proxy del AI Gateway), `8110` (status del Data Plane), `8089` (WireMock). Configurables con `AIGW_PROXY_PORT`, `AIGW_STATUS_PORT` y `AIGW_WIREMOCK_PORT`. | Ver [sección 5.1](#51-puertos-locales-que-deben-estar-libres) |
| Konnect | Permiso para crear un **AI Gateway** (versión 2.2) en la organización del curso; el PAT del participante debe poder administrarlo. | Lab IA 00 |
| Red | Salida HTTPS a `registry.ollama.ai` / `ollama.com` (modelos), `github.com` (kongctl) y `ghcr.io`. | Ver [Requerimientos de Red](Requerimientos_Red_Workshop.md) |

!!! warning "Codespaces: máquina de 4 núcleos / 16 GB"
    El devcontainer del curso exige una máquina de **4 núcleos / 16 GB** (`hostRequirements`), suficiente para los cuatro días. La de 2 núcleos / 8 GB **no alcanza** para el Día 4 con Ollama (Data Plane + Redis + WireMock + Ollama + modelos). Si creas un Codespace sin el devcontainer (por ejemplo, un Codespace en blanco), elige igualmente la máquina de 4 núcleos / 16 GB.

Validación previa (también se hace en el Health Check del final del Día 3):

```bash
kongctl version
docker pull kong/kong-ai-gateway:2.2.0
docker pull ollama/ollama:latest
```

# 9. Referencias oficiales para instalación

Estas referencias se incluyen para alumnos que necesiten validar
compatibilidad, versiones actuales o instrucciones alternativas de
instalación.

- Docker Desktop: https://docs.docker.com/desktop/

- Docker Desktop para macOS:
 https://docs.docker.com/desktop/setup/install/mac-install/



- Docker Desktop para Linux:
 https://docs.docker.com/desktop/setup/install/linux/

- Kong decK: https://developer.konghq.com/deck/

- Insomnia: https://insomnia.rest/

- Terraform: https://developer.hashicorp.com/terraform/install

- Node.js / npm:
 https://docs.npmjs.com/downloading-and-installing-node-js-and-npm/

