# Network Requirements - Kong Konnect Workshop

The following document details the connectivity requirements necessary for the correct execution of the workshop environment, which includes Kong Data Planes (Internal and External), the observability stack (OpenTelemetry Collector, OpenObserve, and Arize Phoenix), and local test microservices. **Days 3 and 4 (AI Gateway)** add the Kong AI Gateway 2.2 Data Plane, Redis Stack, WireMock, and Ollama.

---

## 1. Inbound Rules
*Allow traffic to reach the machine/server where the workshop environment is running.*

| Source | Destination | Port | Protocol | Service / Process | Description (Justification) |
| :--- | :--- | :---: | :---: | :--- | :--- |
| Corporate Network / VPN | Machine / Server IP | **8000** | TCP | Kong DP | Incoming HTTP traffic to the API Gateway. |
| Corporate Network / VPN | Machine / Server IP | **8443** | TCP | Kong DP | Incoming HTTPS traffic to the API Gateway. |
| Corporate Network / VPN | Machine / Server IP | **5080** | TCP | OpenObserve UI | Access to the observability web interface (traces, metrics, logs, dashboards). |
| Corporate Network / VPN | Machine / Server IP | **6006** | TCP | Arize Phoenix UI | Access to the LLM / AI-oriented trace viewer. |
| Participants' Data Planes | Instructor Server IP | **4318** | TCP | OTel Collector (OTLP/HTTP) | (Centralized mode only) Ingestion of traces, logs, and metrics sent by Kong. |
| Corporate Network / VPN | Machine / Server IP | **9081** | TCP | MockAPI Backend | (Optional) Direct access to the test backend microservice. |
| Corporate Network / VPN | Machine / Server IP | **8090** | TCP | MockAPI Mock | (Optional) Direct access to the flights microservice. |
| Corporate Network / VPN | Machine / Server IP | **8010** | TCP | Kong AI Gateway DP | (Days 3–4) AI Gateway proxy: OpenAI-compatible endpoint, MCP and A2A. Configurable with `AIGW_PROXY_PORT`. |
| Corporate Network / VPN | Machine / Server IP | **8110** | TCP | Kong AI Gateway DP | (Days 3–4) Data Plane status / health check. Configurable with `AIGW_STATUS_PORT`. |
| Corporate Network / VPN | Machine / Server IP | **8089** | TCP | WireMock | (Days 3–4) Simulated banking core REST APIs, A2A agents and failing provider. Configurable with `AIGW_WIREMOCK_PORT`. |

---

## 2. Outbound Rules - CRITICAL
*Allow the workshop machine to communicate with the Internet (SaaS and Repositories).*

| Source | Destination | Port | Protocol | Description (Justification) |
| :--- | :--- | :---: | :---: | :--- |
| Machine / Server IP | `*.konghq.com` | **443** | TCP (HTTPS) | **Essential for Kong Konnect.** Local Data Planes need to connect to the cloud Control Plane to continuously download configuration and send telemetry. |
| Machine / Server IP | `hub.docker.com` / `ghcr.io` | **443** | TCP (HTTPS) | Required for Docker to download Kong, observability stack (OTel Collector, OpenObserve, Phoenix), and microservice images. |
| Machine / Server IP | `github.com` / `*.githubusercontent.com` | **443** | TCP (HTTPS) | Required for cloning workshop repositories or downloading scripts/exercises, and to download **kongctl** (`github.com/Kong/kongctl/releases`, `objects.githubusercontent.com`). |
| Machine / Server IP | `registry.ollama.ai` / `ollama.com` | **443** | TCP (HTTPS) | (Days 3–4) Download of the Ollama open-weight models (`llama3.2:1b`, `qwen3:0.6b`, `nomic-embed-text`, ~2.1 GB) in AI Lab 00. |
| Machine / Server IP | `ghcr.io` | **443** | TCP (HTTPS) | (Days 3–4, instructor) Headroom image for the prompt compression demo. |
| Instructor Machine IP | `docker.cloudsmith.io` | **443** | TCP (HTTPS) | (Day 3, instructor, optional) Kong's private AI PII image for the anonymization demo. |
| Instructor Machine IP | `api.openai.com`, `api.anthropic.com`, `generativelanguage.googleapis.com` | **443** | TCP (HTTPS) | (Day 3, instructor, optional) Demos with commercial LLM providers. Participants do not need them: Day 4 uses local models only. |

---

### Additional Notes
*   **Internal Services:** When the observability stack runs on each participant's machine, OpenTelemetry ingestion (`4317`, `4318`) and the Collector health check (`13133`, `127.0.0.1` only) operate over Docker's private virtual network (`kong-workshop` / `otel-stack`). It is not necessary to expose them at the corporate firewall level; `4318` only needs to be opened if the instructor uses a centralized stack.
*   **Execution in Codespaces/Local:** If this environment is run strictly in GitHub Codespaces or on each participant's personal workstation, *Inbound* rules only need to ensure that the environment does not block local listening ports. *Outbound* rules remain mandatory at the perimeter level.