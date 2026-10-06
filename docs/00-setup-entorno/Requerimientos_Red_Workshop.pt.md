# Requisitos de Rede - Workshop Kong Konnect

O documento a seguir detalha os requisitos de conectividade necessários para a correta execução do ambiente de workshop, que inclui os Planos de Dados Kong (Interno e Externo), a stack de observabilidade (OpenTelemetry Collector, OpenObserve e Arize Phoenix) e microsserviços de teste locais. Para os **Dias 3 e 4 (AI Gateway)** somam-se o Data Plane do Kong AI Gateway 2.2, Redis Stack, WireMock e Ollama.

---

## 1. Regras de entrada
*Permitir que o tráfego chegue à máquina/servidor onde o ambiente da oficina está sendo executado.*

| Origem (Fonte) | Destino (Destino) | Porta | Protocolo | Serviço/Processo | Descrição (Justificação) |
| :--- | :--- | :---: | :---: | :--- | :--- |
| Rede Corporativa / VPN | IP da máquina/servidor | **8000** | TCP | Kong DP | Tráfego HTTP de entrada para o API Gateway. |
| Rede Corporativa / VPN | IP da máquina/servidor | **8443** | TCP | Kong DP | Tráfego HTTPS de entrada para o API Gateway. |
| Rede Corporativa / VPN | IP da máquina/servidor | **5080** | TCP | IU OpenObserve | Acesso à interface web de observabilidade (traces, métricas, logs, dashboards). |
| Rede Corporativa / VPN | IP da máquina/servidor | **6006** | TCP | IU Arize Phoenix | Acesso ao visualizador de traces orientado a LLM / IA. |
| Data Planes dos participantes | IP do servidor do instrutor | **4318** | TCP | OTel Collector (OTLP/HTTP) | (Somente no modo centralizado) Ingestão de traces, logs e métricas enviados pelo Kong. |
| Rede Corporativa / VPN | IP da máquina/servidor | **9081** | TCP | Back-end da MockAPI | (Opcional) Acesso direto ao microsserviço de back-end de teste. |
| Rede Corporativa / VPN | IP da máquina/servidor | **8090** | TCP | Simulação de API | (Opcional) Acesso direto ao microsserviço de voos. |
| Rede Corporativa / VPN | IP da máquina/servidor | **8010** | TCP | Kong AI Gateway DP | (Dias 3–4) Proxy do AI Gateway: endpoint compatível com OpenAI, MCP e A2A. Configurável com `AIGW_PROXY_PORT`. |
| Rede Corporativa / VPN | IP da máquina/servidor | **8110** | TCP | Kong AI Gateway DP | (Dias 3–4) Status / health check do Data Plane. Configurável com `AIGW_STATUS_PORT`. |
| Rede Corporativa / VPN | IP da máquina/servidor | **8089** | TCP | WireMock | (Dias 3–4) Core bancário REST, agentes A2A e provedor fora do ar simulados. Configurável com `AIGW_WIREMOCK_PORT`. |

---

## 2. Regras de saída - CRÍTICA
*Permitir que a máquina da oficina se comunique com a Internet (SaaS e Repositórios).*

| Origem (Fonte) | Destino (Destino) | Porta | Protocolo | Descrição (Justificação) |
| :--- | :--- | :---: | :---: | :--- |
| IP da máquina/servidor | `*.konghq.com` | **443** | TCP (HTTPS) | **Essencial para Kong Konnect.** Os planos de dados locais precisam se conectar ao plano de controle na nuvem para baixar a configuração e enviar telemetria continuamente. |
| IP da máquina/servidor | `hub.docker.com` / `ghcr.io` | **443** | TCP (HTTPS) | Necessário para que o Docker possa baixar imagens do Kong, da stack de observabilidade (OTel Collector, OpenObserve, Phoenix) e microsserviços. |
| IP da máquina/servidor | `github.com` / `*.githubusercontent.com` | **443** | TCP (HTTPS) | Necessário para clonar repositórios de workshops ou baixar scripts/exercícios, e para baixar o **kongctl** (`github.com/Kong/kongctl/releases`, `objects.githubusercontent.com`). |
| IP da máquina/servidor | `registry.ollama.ai` / `ollama.com` | **443** | TCP (HTTPS) | (Dias 3–4) Download dos modelos open-weight do Ollama (`llama3.2:1b`, `qwen3:0.6b`, `nomic-embed-text`, ~2,1 GB) no Lab IA 00. |
| IP da máquina/servidor | `ghcr.io` | **443** | TCP (HTTPS) | (Dias 3–4, instrutor) Imagem do Headroom para a demo de compressão de prompts. |
| IP da máquina do instrutor | `docker.cloudsmith.io` | **443** | TCP (HTTPS) | (Dia 3, instrutor, opcional) Imagem privada AI PII da Kong para a demo de anonimização. |
| IP da máquina do instrutor | `api.openai.com`, `api.anthropic.com`, `generativelanguage.googleapis.com` | **443** | TCP (HTTPS) | (Dia 3, instrutor, opcional) Demos com provedores comerciais de LLM. Os participantes não precisam deles: o Dia 4 usa apenas modelos locais. |

---

### Notas Adicionais
* **Serviços internos:** Quando a stack de observabilidade roda na máquina de cada participante, a ingestão OpenTelemetry (`4317`, `4318`) e o health check do Collector (`13133`, somente `127.0.0.1`) operam na rede privada virtual Docker (`kong-workshop` / `otel-stack`). Não há necessidade de expô-los no nível do firewall corporativo; só é preciso abrir a `4318` se o instrutor usar uma stack centralizada.
* **Execução em Codespaces/Local:** Se este ambiente estiver sendo executado estritamente em GitHub Codespaces ou na estação de trabalho pessoal de cada participante, as regras *Inbound* devem apenas garantir que o ambiente não bloqueie portas de escuta locais. As regras de *saída* ainda são obrigatórias no nível do perímetro.
