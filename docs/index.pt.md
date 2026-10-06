# Workshop Kong API Gateway & Konnect



Bem-vindo ao material oficial do Workshop **Kong API Gateway & Konnect**. 
Este curso presencial de **quatro dias** tem como objetivo fornecer treinamento prático em API Gateway, AI Gateway, GitOps, Segurança e Observabilidade: o **Dia 1** combina teoria e demonstrações, o **Dia 2** é dedicado a laboratórios práticos, o **Dia 3** apresenta o **Kong AI Gateway** com teoria e demonstrações, e o **Dia 4** é dedicado a laboratórios práticos de AI Gateway.

![Visão geral do Kong Konnect](./public/konnect_unified_api_platform.png)

---

## Descrição e objetivos

Todo o workshop usa uma abordagem **GitOps** com gerenciamento declarativo via **decK** (Dias 1–2) e **kongctl** (AI Gateway, Dias 3–4), automação com **Terraform** e back-ends simulados com Docker.

### Testar back-end: httpbin
Como fio condutor de nossas práticas e demonstrações, usaremos **httpbin** como nosso back-end de teste simulado. Em nosso ambiente local, este serviço já está pré-implantado usando Docker (no contêiner `httpbin-backend`). `httpbin` é uma ferramenta genérica amplamente utilizada para testar solicitações HTTP; Ele nos permite verificar facilmente quais cabeçalhos, métodos e corpos de mensagens estão realmente chegando ao back-end após passar pelo API Gateway. 

Nosso trabalho durante o workshop será expor, proteger e gerenciar o tráfego para essas APIs de teste usando Kong Konnect, permitindo-nos focar em roteamento, transformações e políticas de segurança sem depender de lógica de negócios complexa no backend.



### Dia 1: Bloco Teórico — Fundamentos, Operações e Segurança
**Teoria Integral de Kong Konnect**

- **Arquitetura conceitual**: Entenda a separação entre plano de controle (Konnect) e plano de dados (Kong Gateway baseado em NGINX/OpenResty) e comunicação via túnel gRPC mTLS.
- **Developer Track**: Conceitos de Gateway Services, Rotas, Plugins, Portal do Desenvolvedor e publicação de APIs de Catálogo.
- **Operations Track**: Governança declarativa com deck/Terraform, monitoramento de tráfego e observabilidade avançada com OpenTelemetry (OpenObserve + Arize Phoenix).
- **Security Track**: Zero Trust, OIDC, RBAC e estratégias de controle de acesso através de OPA.
- **Demos complementares**: Integração ITSM, Gerenciamento de Segredos (Vaults) e Segurança OWASP / WAF.

### Dia 2: Bloco Prático — Laboratórios práticos
**Laboratórios e práticas guiadas**

- **Configuração e Roteamento**: Inicialização do ambiente local e implantação declarativa de rotas.
- **Plugins e Portais**: Transformações de payload, roteamento inteligente e publicação de catálogos OAS.
- **Operações e Segurança**: Implantação de observabilidade local (OTel Collector + OpenObserve + Phoenix), aplicação Key Auth, restrição de IP e OIDC.
- **Event Gateway**: Integração assíncrona enviando mensagens para tópicos Kafka (Event-Driven Architecture).

### Dia 3: AI Gateway — Teoria e Demonstrações
**Kong AI Gateway 2.2 no Konnect, governado com kongctl**

- **Arquitetura 2.x**: Control Plane próprio no Konnect (modelos, provedores, policies, MCP, agentes), Data Plane `kong/kong-ai-gateway:2.2.0` e APIOps com kongctl.
- **Acesso e governança**: um endpoint compatível com OpenAI para modelos locais e comerciais, failover, passthrough, ACL por modelo, cotas de tokens e orçamento em USD.
- **Segurança e otimização**: guardrails (regex e semânticos), PII, roteamento semântico, cache semântico, compressão e RAG gerenciado.
- **Agentes**: APIs REST como tools MCP com ACL por agente, A2A, observabilidade de IA (OpenObserve + Phoenix), FinOps e Metering & Billing; novidades do AI Summit 2026.

### Dia 4: AI Gateway — Laboratórios práticos
**Cada participante constrói o seu próprio AI Gateway, sem chaves pagas**

- **Setup**: AI Gateway no Konnect + Data Plane 2.2 no Docker + Ollama com modelos open-weight pequenos (CPU).
- **Labs**: multi-LLM e failover, cotas e orçamento, guardrails, semântica e cache, RAG, MCP, A2A, observabilidade.
- **Desafio final**: assistente de crédito governado (bancário).

---

## Agenda completa do workshop

O workshop está planejado em quatro dias estruturados: os Dias 1 e 2 das **08h00 às 17h00** e os Dias 3 e 4 (AI Gateway) das **08h00 às 16h30**:

### Dia 1: Teórico e Demonstrações
| Cronograma | Bloco | Tópico/Módulo |
|--------|--------|---------------|
| **08:00 - 08:30** | Manhã (Todos) | Bem-vindo, Arquitetura e Configuração Conceitual |
| **08:30 - 09:15** | Manhã (Dev) | Módulo 00: Arquitetura Conceitual e Configuração Local |
| **09:15 - 10:15** | Manhã (Dev) | Módulo 01: Gateway Kong Konnect e planos de controle |
| **10h15 - 10h30** | - | *Coffee Break* |
| **10h30 - 12h00** | Manhã (Dev) | Módulo 02: Ecossistema de Plugins Kong |
| **12h00 - 13h00** | Manhã (Dev) | Módulo 03: Portal do Desenvolvedor, Customização e Onboarding |
| **13h00 - 14h15** | - | *Almoço (saída dos desenvolvedores)* |
| **14h15 - 15h15** | Tarde (Ops) | Módulo 04: Operações de Gateway e GitOps (decK / Terraform) |
| **15h15 - 15h45** | Tarde (Ops) | Módulo 05: Monitoramento e registro (Konnect Analytics) |
| **15h45 - 16h00** | - | *Coffee Break* |
| **16:00 - 16:45** | Tarde (Ops) | Módulo 06: Observabilidade Avançada (OpenTelemetry / OpenObserve / Phoenix) |
| **16h45 - 17h30** | Tarde (Sec) | Módulo 07: Protegendo o tráfego da API (Key Auth, ACL, OIDC, IP Restriction) |
| **17h30 - 17h45** | Tarde (Todos) | **Health Check dos ambientes** (Preparação do Dia 2) |

### Dia 2: Prática — Laboratórios práticos e encerramento
| Cronograma | Bloco | Laboratório/Atividade Prática |
|--------|--------|----------------------------------|
| **08:00 - 08:15** | Manhã (Todos) | Bem-vindo ao Dia Prático, credenciais e revisão do GitOps |
| **08h15 - 09h00** | Manhã (Dev) | **Laboratório:** Configuração do ambiente local |
| **09:00 - 09:50** | Manhã (Dev) | **Laboratório:** Roteamento declarativo + upstreams e verificações de integridade |
| **09h50 - 10h05** | - | *Coffee Break* |
| **10h05 - 11h20** | Manhã (Dev) | **Laboratório:** Catálogo de APIs e OAS + Transformações |
| **11h20 - 12h00** | Manhã (Dev) | **Laboratórios Avançados:** Roteamento Inteligente e Validação JSON |
| **12h00 - 13h00** | - | *Almoço (saída dos desenvolvedores / entrada das operações)* |
| **13h00 - 13h15** | Tarde (Todos) | Boas-vindas e sincronização de ambientes (Participantes da Tarde) |
| **13h15 - 14h15** | Tarde (Ops) | **Laboratório:** Observabilidade distribuída com OTel, OpenObserve e Phoenix |
| **14h15 - 15h25** | Tarde (Sec) | **Laboratório:** Autenticação de chave Zero Trust + OIDC e ACL |
| **15h25 - 15h40** | - | *Coffee Break* |
| **15h40 - 16h25** | Tarde (Sec) | **Laboratório:** Restrição de IP + Autorização OPA |
| **16h25 - 17h00** | Tarde (Todos) | Encerramento do workshop, resolução de dúvidas e próximos passos |

### Dia 3: AI Gateway — Teoria e Demonstrações
| Cronograma | Bloco | Tópico/Módulo |
|--------|--------|---------------|
| **08h00 - 08h15** | Manhã (Todos) | Boas-vindas e objetivos do bloco de IA |
| **08h15 - 09h00** | Manhã (Dev) | Módulo IA 00: Arquitetura AI Gateway 2.x no Konnect e kongctl |
| **09h00 - 09h45** | Manhã (Dev) | Módulo IA 01: Um endpoint, muitos LLMs |
| **09h45 - 10h00** | - | *Coffee Break* |
| **10h00 - 10h45** | Manhã (Sec) | Módulo IA 02: Governança, cotas de tokens e orçamento |
| **10h45 - 11h30** | Manhã (Sec) | Módulo IA 03: Guardrails e PII |
| **11h30 - 12h10** | Manhã (Dev) | Módulo IA 04: Roteamento semântico, cache e compressão |
| **12h10 - 13h10** | - | *Almoço* |
| **13h10 - 13h35** | Tarde (Dev) | Módulo IA 05: RAG gerenciado |
| **13h35 - 14h25** | Tarde (Dev) | Módulo IA 06: MCP — APIs como tools, bundling e ACL por agente |
| **14h25 - 14h50** | Tarde (Dev) | Módulo IA 07: Agentes e A2A |
| **14h50 - 15h05** | - | *Coffee Break* |
| **15h05 - 15h50** | Tarde (Ops) | Módulo IA 08: Observabilidade e FinOps de IA, Metering & Billing |
| **15h50 - 16h10** | Tarde (Todos) | Módulo IA 09: Novidades do AI Summit 2026 e roadmap |
| **16h10 - 16h30** | Tarde (Todos) | **Health Check dos ambientes** para o Dia 4 (kongctl ≥ 1.20.1, Docker, download dos modelos) |

### Dia 4: AI Gateway — Laboratórios práticos
| Cronograma | Bloco | Laboratório |
|--------|--------|-------------|
| **08h00 - 08h45** | Manhã (Todos) | **Lab IA 00:** Setup do AI Gateway (Konnect + DP 2.2 + Ollama) |
| **08h45 - 09h20** | Manhã (Dev) | **Lab IA 01:** Multi-LLM, failover e passthrough |
| **09h20 - 10h00** | Manhã (Sec) | **Lab IA 02:** Governança: ACL, cotas e orçamento |
| **10h00 - 10h15** | - | *Coffee Break* |
| **10h15 - 10h50** | Manhã (Sec) | **Lab IA 03:** Guardrails |
| **10h50 - 11h25** | Manhã (Dev) | **Lab IA 04:** Roteamento semântico e cache |
| **11h25 - 11h55** | Manhã (Dev) | **Lab IA 05:** RAG |
| **11h55 - 12h55** | - | *Almoço* |
| **12h55 - 13h40** | Tarde (Dev) | **Lab IA 06:** MCP |
| **13h40 - 14h05** | Tarde (Dev) | **Lab IA 07:** A2A |
| **14h05 - 14h50** | Tarde (Ops) | **Lab IA 08:** Observabilidade de IA (OpenObserve + Phoenix) |
| **14h50 - 15h05** | - | *Coffee Break* |
| **15h05 - 15h50** | Tarde (Todos) | **Desafio IA (opcional):** Assistente de crédito governado |
| **15h50 - 16h15** | Tarde (Todos) | Encerramento do curso, limpeza dos ambientes (`aplicar.sh 00`, `teardown.sh --all`) e próximos passos |

!!! note "Conteúdo opcional"
    As demos complementares do Dia 1 (ITSM, Segredos, OWASP / WAF) e o Lab 12 (Event Gateway com Kafka) não fazem parte da agenda base: são programados conforme o tempo disponível e o perfil do público.
