# Requisitos de Rede - Workshop Kong Konnect

O documento a seguir detalha os requisitos de conectividade necessários para a correta execução do ambiente de workshop, que inclui os Planos de Dados Kong (Interno e Externo), a stack de observabilidade (OpenTelemetry Collector, OpenObserve e Arize Phoenix) e microsserviços de teste locais.

---

## 1. Regras de entrada
*Permitir que o tráfego chegue à máquina/servidor onde o ambiente da oficina está sendo executado.*

| Origem (Fonte) | Destino (Destino) | Porto | Protocolo | Serviço/Processo | Descrição (Justificação) |
| :--- | :--- | :---: | :---: | :--- | :--- |
| Rede Corporativa / VPN | IP da máquina/servidor | **8.000** | TCP | Kong DP | Tráfego HTTP de entrada para o API Gateway. |
| Rede Corporativa / VPN | IP da máquina/servidor | **8443** | TCP | Kong DP | Tráfego HTTPS de entrada para o API Gateway. |
| Rede Corporativa / VPN | IP da máquina/servidor | **5080** | TCP | IU OpenObserve | Acesso à interface web de observabilidade (traces, métricas, logs, dashboards). |
| Rede Corporativa / VPN | IP da máquina/servidor | **6006** | TCP | IU Arize Phoenix | Acesso ao visualizador de traces orientado a LLM / IA. |
| Data Planes dos participantes | IP do servidor do instrutor | **4318** | TCP | OTel Collector (OTLP/HTTP) | (Somente no modo centralizado) Ingestão de traces, logs e métricas enviados pelo Kong. |
| Rede Corporativa / VPN | IP da máquina/servidor | **9081** | TCP | Back-end da MockAPI | (Opcional) Acesso direto ao microsserviço de back-end de teste. |
| Rede Corporativa / VPN | IP da máquina/servidor | **8090** | TCP | Simulação de API | (Opcional) Acesso direto ao microsserviço de voos. |

---

## 2. Regras de saída - CRÍTICA
*Permitir que a máquina da oficina se comunique com a Internet (SaaS e Repositórios).*

| Origem (Fonte) | Destino (Destino) | Porto | Protocolo | Descrição (Justificação) |
| :--- | :--- | :---: | :---: | :--- |
| IP da máquina/servidor | `*.konghq.com` | **443** | TCP (HTTPS) | **Essencial para Kong Konnect.** Os planos de dados locais precisam se conectar ao plano de controle na nuvem para baixar a configuração e enviar telemetria continuamente. |
| IP da máquina/servidor | `hub.docker.com` / `ghcr.io` | **443** | TCP (HTTPS) | Necessário para que o Docker possa baixar imagens do Kong, da stack de observabilidade (OTel Collector, OpenObserve, Phoenix) e microsserviços. |
| IP da máquina/servidor | `github.com` / `*.githubusercontent.com` | **443** | TCP (HTTPS) | Necessário para clonar repositórios de workshops ou baixar scripts/exercícios. |

---

## # Notas Adicionais
* **Serviços internos:** Quando a stack de observabilidade roda na máquina de cada participante, a ingestão OpenTelemetry (`4317`, `4318`) e o health check do Collector (`13133`, somente `127.0.0.1`) operam na rede privada virtual Docker (`kong-workshop` / `otel-stack`). Não há necessidade de expô-los no nível do firewall corporativo; só é preciso abrir a `4318` se o instrutor usar uma stack centralizada.
* **Execução em Codespaces/Local:** Se este ambiente estiver sendo executado estritamente em GitHub Codespaces ou na estação de trabalho pessoal de cada participante, as regras *Inbound* devem apenas garantir que o ambiente não bloqueie portas de escuta locais. As regras de *saída* ainda são obrigatórias no nível do perímetro.
