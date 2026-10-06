KONG

Installation Prerequisites

Kong Konnect Workshop

Simple Guide to Prepare the Student Workstation

| Field | Detail |
|---|---|
| Provider | KONG |
| Platform | Kong Konnect - hybrid architecture with SaaS Control Plane and local lab environments |
| Objective | Indicate what each student must install, what must be configured in Konnect, and what connectivity they must have from their workstation. |
| Version | 0.4 |
| Date | 26-Aug-2026 |

Important: Do not include real Konnect tokens in documents, emails,
tickets, or repositories. Each student must use their own PAT or a
temporary token provided by the instructor.

1\. Objective of this Document

This document practically summarizes what each student must have
ready before the Kong Konnect workshop. The focus is on preparing the
laptop to run local exercises, manage declarative configuration with
decK, import collections into Insomnia, spin up lab services with Docker,
and validate connection against the assigned Kong Konnect instance.

The document does not replace the lab guide. Its purpose is to
serve as a preliminary checklist to prevent workshop time from being
consumed by installing basic tools or resolving network blocks.

# Choose your path: Codespaces (A) or local install (B)

!!! tip "Path A — GitHub Codespaces (recommended)"
    A cloud Linux environment, ready in ~5 minutes, with **Docker, decK, kongctl, inso, Terraform, Node.js, Python and jq** preinstalled. All you need is a browser and a GitHub account with access to the course repository. It avoids the usual corporate-laptop restrictions (unlicensed or blocked Docker Desktop, Windows without WSL2, proxies, missing admin rights).

    [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/rzengin/Kong-Konnect-Fundamentals?quickstart=1)

    1. Click the button (or on GitHub: **Code → Codespaces → Create codespace on main**). Pick the **4-core / 16 GB** machine (required by the devcontainer and needed for Day 4 with Ollama).
    2. Wait for creation to finish: the container runs `docs/00-setup-entorno/scripts/install_prereqs.sh` automatically.
    3. Set your variables (preferably as [Codespaces secrets](https://github.com/settings/codespaces) `KONNECT_TOKEN` and `DEMO_PREFIX`, or in the terminal):
       ```bash
       export KONNECT_TOKEN="kpat_..."   # provided by the instructor
       export DEMO_PREFIX="your_name"
       ```
    4. Lab ports are forwarded automatically (**Ports** tab): 8000/8443 Kong proxy, 8001 Admin API, 5080 OpenObserve, 6006 Phoenix, 4318 OTLP and, for Days 3–4, 8010 AI Gateway proxy, 8110 Data Plane status and 8089 WireMock. Wherever the guides say `http://localhost:<port>`, use `curl` from the Codespace terminal or open the forwarded URL from the **Ports** tab.

    With path A you can jump straight to [section 4](#4-required-configuration-in-kong-konnect) (Konnect configuration); sections 2–3 only apply to a local install.

!!! note "Path B — Local install"
    If you prefer to work on your laptop (or have no Codespaces access), install the tools following sections 2 and 3. On macOS and Linux the `docs/00-setup-entorno/scripts/install_prereqs.sh` script automates most of it.

# 2. Minimum Checklist Before the Workshop

| **Category** | **Requirement (Minimum Version)** | **Usage in Exercises** |
|---|---|---|
| Operating system | macOS, Linux, or Windows (CMD) | Run CLI, Docker, scripts, and local tests. |
| Docker | Docker Desktop or Docker Engine (v20.10+) with Docker Compose (v2.x) | Spin up local Kong Data Plane, mocks, Keycloak, WireMock, Prism, and observability stack. |
| Git | Git client installed (v2.20+) | Clone or receive the workshop assets repository. |
| curl | curl CLI available (v7.0+) | Test APIs, Konnect, mocks, and local endpoints. |
| jq | Command-line JSON processor (v1.6+) | Read JSON responses from APIs and scripts. |
| decK | decK CLI (v1.65+) or version indicated by the instructor | Synchronize services, routes, plugins, and consumers against Konnect. |
| kongctl | kongctl CLI (v1.20.1+) | Days 3–4: declarative configuration of the AI Gateway in Konnect (see [section 8](#8-days-3-and-4-ai-gateway-additional-requirements)). |
| Insomnia | Insomnia desktop application (v8.0+) | Import collections, OpenAPI, and run manual tests or Runner. |
| Terraform | Terraform CLI (v1.5+), required for APIOps/Portal/Catalog exercises | Manage platform resources when the lab includes it. |
| Node.js / npm / inso | Node.js LTS (v18+) and, if applicable, Insomnia CLI | Run terminal tests with inso and supporting utilities. |
| Editor | VS Code or another text editor | Edit YAML, OpenAPI, .env, and scripts. |

# 3. Installation by Operating System

### 3.1 Windows (CMD)

If you use Windows and will run the workshop from the `cmd.exe` command line:

- **Docker:** Install [Docker Desktop for Windows](https://docs.docker.com/desktop/setup/install/windows-install/).
- **Git and curl:** Usually included in Windows 10/11. You can install Git by downloading it from [git-scm.com](https://git-scm.com/).
- **decK CLI:** You can install it via `winget` or by downloading the binary:
  ```cmd
  winget install Kong.decK
  ```
- **jq:** You can install it via `winget`:
  ```cmd
  winget install jqlang.jq
  ```
- **Terraform:**
  ```cmd
  winget install Hashicorp.Terraform
  ```

### 3.2 macOS (Intel or Apple Silicon)

The following instructions are practical. If KONG uses
corporate packagers, Intune, SCCM, Jamf, internal repositories, or
software restrictions, use the equivalent corporate mechanism and
then run the validations in section 6.

## 3.1 macOS

Recommended option: Homebrew for CLI tools and
Docker Desktop and Insomnia download/installation. Open Terminal and
run:

```bash
# 1) Install Apple base tools if they don't exist
xcode-select --install

# 2) Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL
https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3) Update Homebrew
brew update

# 4) Install CLI tools
brew install git curl python@3.12 node kong/deck/deck
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# 5) Install desktop applications
brew install --cask docker insomnia visual-studio-code
```

After installing Docker Desktop:

1. Open Docker Desktop from Applications.

2. Accept Docker Desktop terms of use according to KONG policy.

3. In Settings \> Resources, allocate at least 4 GB of memory if the
  laptop allows it. The observability stack (Module 06 / Lab 07:
  OTel Collector + OpenObserve + Arize Phoenix) uses ~1.2 GB of that
  total; the extra ~4 GB required by the previous platform are no longer needed.

4. Wait for Docker to indicate Running status.

Quick validation on macOS:

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

The following instructions cover Ubuntu/Debian. For Fedora/RHEL,
use dnf and equivalent rpm packages. On Linux, you can use Docker
Desktop or Docker Engine; for the workshop, Docker Engine with Docker
Compose is usually sufficient.

### 3.3.1 Ubuntu/Debian - Base Tools

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release git 
unzip python3 python3-pip
```

### 3.3.2 Ubuntu/Debian - Docker Engine and Docker Compose

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

# Log out and log back in for the docker group to apply.
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

Download the Linux package from the official Insomnia website. If a
.deb is downloaded, install it from the Downloads folder as follows:

```bash
cd ~/Downloads
sudo apt install ./Insomnia\*.deb
```

Quick validation on Linux:

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

# 4. Required Configuration in Kong Konnect

Each student must have access to the Konnect organization used in the
workshop and to the Control Plane assigned for the exercises. The
instructor or platform administrator must validate these points before
starting.

| **Element** | **Must be ready** | **Expected validation** |
|---|---|---|
| Konnect Account | Invited user with access to the workshop organization. | The student can log in to Konnect. |
| Control Plane | Control Plane available for exercises. For this guide: `your_name_MockAPI` | The student can view the Control Plane in Konnect. |
| Permissions | Sufficient permissions to read Data Plane Nodes and manage services, routes, plugins, consumers, and credentials according to the lab. | The student can run `deck gateway ping` and synchronize configuration if the exercise requires it. |
| Personal Access Token | Personal PAT or temporary token provided by the instructor. Must not be shared or documented. | The token allows decK to connect to Konnect. |
| Local Data Plane | Assets, certificates, or docker-compose provided by the instructor if the student needs to spin up their own Data Plane. | In Konnect, the Data Plane must appear connected and, when applicable, in an In Sync state. |

## 4.1 Environment Variables

Use the values defined for the workshop. The actual token must be
entered by each student on their own workstation.

```bash
# macOS / Linux / Codespaces
export KONNECT_TOKEN="<PERSONAL_PAT_OR_TEMPORARY_TOKEN>"
export DEMO_PREFIX="your_name"
export KONNECT_CONTROL_PLANE_NAME="${DEMO_PREFIX}_MockAPI"
export CONTROL_PLANE_NAME="$KONNECT_CONTROL_PLANE_NAME"
export KONNECT_ADDR="https://us.api.konghq.com"
```

## 4.2 .deck.yaml File

If the workshop repository includes a setup script, use that script.
If the file needs to be created manually, from the lab folder:

```bash
# macOS / Linux / Codespaces
cat > .deck.yaml <<EOF
konnect-token: "$KONNECT_TOKEN"
konnect-addr: "$KONNECT_ADDR"
konnect-control-plane-name: "$KONNECT_CONTROL_PLANE_NAME"
EOF

# Validate
deck gateway ping
```

# 5. Required Connectivity from the Workstation

Before the workshop, validate that the corporate network, VPN, proxy,
antivirus, and local firewall do not block necessary communication. If
KONG uses TLS inspection, it may be necessary to allow exceptions for
Konnect domains and software repositories.

| Destination / Port | Usage | Requirement |
|------------------|-----|-----------|
| `https://us.api.konghq.com:443` | Konnect API used by decK and scripts. | HTTPS outbound allowed from the laptop. |
| Konnect runtime domains / `*.konghq.com:443` | Local Data Plane connection with the SaaS Control Plane. | TLS outbound allowed; avoid breakage due to TLS inspection. |
| `github.com` / `releases.githubusercontent.com:443` | Download of decK, assets, and dependencies. | HTTPS outbound allowed. |
| `registry-1.docker.io` / `auth.docker.io` / Docker Hub:443 | Download of lab Docker images. | HTTPS outbound allowed; authenticate if the network has rate limits. |
| `npmjs.org` / `nodejs.org` / `deb.nodesource.com:443` | Node.js, npm, and inso CLI when applicable. | HTTPS outbound allowed. |
| `releases.hashicorp.com` / `apt.releases.hashicorp.com:443` | Terraform installation. | HTTPS outbound allowed. |
| `github.com/Kong/terraform-provider-konnect:443` | Download of the kong/konnect provider. | HTTPS outbound allowed. |
| `insomnia.rest` / GitHub releases:443 | Download of Insomnia. | HTTPS outbound allowed. |

## 5.1 Local Ports That Must Be Free

The exercises may spin up several local containers. Before starting,
close services that are using these ports or ask the instructor for
alternative variables.

| Local Port | Typical Service | Usage in Lab |
|-------------|----------------|--------------------|
| 8000 | Kong Proxy | Main entry point for testing APIs exposed by Kong. |
| 8010 | Optional Second Data Plane / AI Gateway proxy | Day 2: clustering / scalability exercise. Days 3–4: AI Gateway proxy (set `AIGW_PROXY_PORT` if both clash). |
| 8110 | AI Gateway Data Plane status | Health check of the 2.2 Data Plane (Days 3–4). |
| 8089 | WireMock (AI Gateway) | Banking core REST APIs (→ MCP), A2A agents and failing provider (Days 3–4). |
| 8080 | Prism Mock | API Mock based on OpenAPI. |
| 9081 | httpbin-backend | Echo backend to validate headers, body, and transformations. |
| 8082 | WireMock | Business API Mock. |
| 8083 | Keycloak | Local OIDC server for authentication exercises. |
| 8100 | Kong metrics | Local Prometheus metrics endpoint. |
| 5080 | OpenObserve | Observability UI: traces, metrics, logs, and dashboards (Module 06 / Lab 07). |
| 6006 | Arize Phoenix | LLM / AI-oriented trace UI (Module 06 / Lab 07). |
| 4317 / 4318 | OpenTelemetry Collector | OTLP gRPC / HTTP reception of traces, metrics, and logs. |
| 13133 | OpenTelemetry Collector | Health check (`127.0.0.1` only). |
| 9092 | Kafka | Broker for Event Gateway tests (Lab 12). |

# 6. Validation Before the Workshop

Run this validation at least one day before the workshop. If any point
fails, raise it as an operational blocker.

## 6.1 Validate Local Tools

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

## 6.2 Validate Docker

```bash
docker run --rm hello-world
docker compose version
```

## 6.3 Validate Connectivity with Konnect

```bash
curl -I https://us.api.konghq.com

deck gateway ping
```

## 6.4 Validate Local Data Plane When Running

```bash
curl -i http://localhost:8000/any-route
```
```bash
# Expected response if Kong is active but without routes:
# HTTP/1.1 404 Not Found
# {"message":"no Route matched with those values"}
```

# 7. Common Problems and Quick Fixes

| **Symptom** | **Probable Cause** | **Suggested Action** |
|---|---|---|
| docker: command not found | Docker not installed or PATH not updated. | Open new terminal and verify installation. |
| Cannot connect to the Docker daemon | Docker Desktop is not started or the user does not belong to the docker group on Linux. | Start Docker Desktop. On Linux, run `usermod -aG docker $USER` and log back in. |
| deck gateway ping fails with 401/403 | Invalid, expired, or unauthorized PAT. | Regenerate PAT or validate permissions in Konnect. |
| deck gateway ping does not resolve DNS or timeout | Proxy, VPN, DNS, or firewall block outbound connection to Konnect. | Validate HTTPS outbound to us.api.konghq.com and Konnect runtime domains. |
| Local port occupied | Another process is using the required port. | Identify process and free port, or ask the instructor for an alternative variable. |
| Docker does not download images | Block to Docker Hub, proxy not configured, or rate limit. | Configure corporate proxy in Docker Desktop or use corporate mirror. |
| Insomnia does not import collection | Incorrect file or outdated version. | Update Insomnia and re-import the provided workspace. |
| terraform init fails with 403/timeout error | Network restriction or proxy prevents downloading the provider. | Perform offline installation of the provider (See Section 7.1). |



# 8. Days 3 and 4 — AI Gateway (Additional Requirements)

Days 3 and 4 use **Kong AI Gateway 2.2** (Control Plane in Konnect + `kong/kong-ai-gateway:2.2.0` Data Plane on Docker) together with Redis Stack, WireMock and **Ollama** with small open-weight models (CPU, no paid API keys). In addition to the above, each participant needs:

| **Requirement** | **Details** | **Validation** |
|---|---|---|
| kongctl | **v1.20.1 or later** (1.16 does not know the AI Gateway 2.1/2.2 entities). Binaries in the [v1.20.1](https://github.com/Kong/kongctl/releases/tag/v1.20.1) release; `install_prereqs.sh` installs or upgrades it. | `kongctl version` |
| Docker | At least **8 GB of RAM** allocated to Docker (10–12 GB if you also run the observability stack of AI Lab 08). | `docker info` |
| Disk | **~6 GB free**: Data Plane image, Redis Stack, WireMock, Ollama and ~2.1 GB of models (`llama3.2:1b`, `qwen3:0.6b`, `nomic-embed-text`). | `docker system df` |
| jq, curl, openssl, python3 | Same as Days 1–2 (make sure `jq` is installed). | `jq --version && python3 --version` |
| Free ports | `8010` (AI Gateway proxy), `8110` (Data Plane status), `8089` (WireMock). Configurable with `AIGW_PROXY_PORT`, `AIGW_STATUS_PORT` and `AIGW_WIREMOCK_PORT`. | See [section 5.1](#51-local-ports-that-must-be-free) |
| Konnect | Permission to create an **AI Gateway** (version 2.2) in the course organization; the participant's PAT must be able to manage it. | AI Lab 00 |
| Network | Outbound HTTPS to `registry.ollama.ai` / `ollama.com` (models), `github.com` (kongctl) and `ghcr.io`. | See [Network Requirements](Requerimientos_Red_Workshop.md) |

!!! warning "Codespaces: 4-core / 16 GB machine"
    The course devcontainer requires a **4-core / 16 GB** machine (`hostRequirements`), which covers all four days. The 2-core / 8 GB machine is **not enough** for Day 4 with Ollama (Data Plane + Redis + WireMock + Ollama + models). If you create a Codespace without the devcontainer (for example, a blank Codespace), choose the 4-core / 16 GB machine as well.

Pre-check (also done in the Health Check at the end of Day 3):

```bash
kongctl version
docker pull kong/kong-ai-gateway:2.2.0
docker pull ollama/ollama:latest
```

# 9. Official Installation References

These references are included for students who need to validate
compatibility, current versions, or alternative installation
instructions.

- Docker Desktop: https://docs.docker.com/desktop/

- Docker Desktop for macOS:
 https://docs.docker.com/desktop/setup/install/mac-install/



- Docker Desktop for Linux:
 https://docs.docker.com/desktop/setup/install/linux/

- Kong decK: https://developer.konghq.com/deck/

- Insomnia: https://insomnia.rest/

- Terraform: https://developer.hashicorp.com/terraform/install

- Node.js / npm:
 https://docs.npmjs.com/downloading-and-installing-node-js-and-npm/