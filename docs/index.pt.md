# Kong API Gateway e workshop Konnect



Bem-vindo ao material oficial do Workshop **Kong API Gateway & Konnect**. 
Este curso presencial de dois dias tem como objetivo fornecer treinamento prático em API Gateway, GitOps, Segurança e Observabilidade.

![Visão geral do Kong Konnect](./public/konnect_unified_api_platform.png)

---

## Descrição e objetivos

Todo o workshop usa uma abordagem **GitOps** com gerenciamento declarativo via **decK**, automação com **Terraform** e back-ends simulados com Docker.

### Testar back-end: httpbin
Como fio condutor de nossas práticas e demonstrações, usaremos **httpbin** como nosso back-end de teste simulado. Em nosso ambiente local, este serviço já está pré-implantado usando Docker (no contêiner `httpbin-backend`). `httpbin` é uma ferramenta genérica amplamente utilizada para testar solicitações HTTP; Ele nos permite verificar facilmente quais cabeçalhos, métodos e corpos de mensagens estão realmente chegando ao back-end após passar pelo API Gateway. 

Nosso trabalho durante o workshop será expor, proteger e gerenciar o tráfego para essas APIs de teste usando Kong Konnect, permitindo-nos focar em roteamento, transformações e políticas de segurança sem depender de lógica de negócios complexa no backend.



### Dia 1: Bloco Teórico — Fundamentos, Operações e Segurança
**Teoria Integral de Kong Konnect**

- **Arquitetura conceitual**: Entenda a separação entre plano de controle (Konnect) e plano de dados (Kong Gateway baseado em NGINX/OpenResty) e comunicação via túnel gRPC mTLS.
- **Developer Track**: Conceitos de Gateway Services, Rotas, Plugins, Portal do Desenvolvedor e publicação de APIs de Catálogo.
- **Operations Track**: Governança declarativa com deck/Terraform, monitoramento de tráfego e observabilidade avançada com OpenTelemetry (OpenObserve + Arize Phoenix).
- **Security Track**: Zero Trust, OIDC, RBAC e estratégias de controle de acesso através de OPA.

### Dia 2: Bloco Prático — Laboratórios práticos e desafio final
**Laboratórios e práticas guiadas**

- **Configuração e Roteamento**: Inicialização do ambiente local e implantação declarativa de rotas.
- **Plugins e Portais**: Transformações de payload, roteamento inteligente e publicação de catálogos OAS.
- **Operações e Segurança**: Implantação de observabilidade local (OTel Collector + OpenObserve + Phoenix), aplicação Key Auth, restrição de IP e OIDC.
- **Event Gateway**: Integração assíncrona enviando mensagens para tópicos Kafka (Event-Driven Architecture).

---

## Agenda completa do workshop

O workshop está planejado em dois dias estruturados das **08h00 às 17h00**:

### Dia 1: Teórico e Demonstrações
| Cronograma | Bloco | Tópico/Módulo |
|--------|--------|---------------|
| **08:00 - 08:30** | Amanhã (todos) | Bem-vindo, Arquitetura e Configuração Conceitual |
| **08:30 - 09:15** | Amanhã (Desenvolvimento) | Módulo 00: Arquitetura Conceitual e Configuração Local |
| **09:15 - 10:15** | Amanhã (Desenvolvimento) | Módulo 01: Gateway Kong Konnect e planos de controle |
| **10h15 - 10h30** | - | *Coffe Break* |
| **10h30 - 12h00** | Amanhã (Desenvolvimento) | Módulo 02: Ecossistema de Plugins Kong |
| **12h00 - 13h00** | Amanhã (Desenvolvimento) | Módulo 03: Portal do Desenvolvedor, Customização e Onboarding |
| **13h00 - 14h15** | - | *Almoço (saída dos desenvolvedores)* |
| **14h15 - 15h15** | Tarde (Ops) | Módulo 04: Operações de Gateway e GitOps (decK / Terraform) |
| **15h15 - 15h45** | Tarde (Ops) | Módulo 05: Monitoramento e registro (Konnect Analytics) |
| **15h45 - 16h00** | - | *Coffe Break* |
| **16:00 - 16:45** | Tarde (Ops) | Módulo 06: Observabilidade Avançada (OpenTelemetry / OpenObserve / Phoenix) |
| **16h45 - 17h30** | Tarde (seg) | Módulo 07: Protegendo o tráfego da API (Key Auth, ACL, OIDC, IP Restriction) |
| **17h30 - 17h45** | Tarde (Todos) | **Verificação de Saúde Ambiental** (Dia de Preparação 2) |

### Dia 2: Prática — Laboratórios práticos e encerramento
| Cronograma | Bloco | Laboratório/Atividade Prática |
|--------|--------|----------------------------------|
| **08:00 - 08:15** | Amanhã (todos) | Bem-vindo ao Dia Prático, credenciais e revisão do GitOps |
| **08h15 - 09h00** | Amanhã (Desenvolvimento) | **Laboratório:** Configuração do ambiente local |
| **09:00 - 09:50** | Amanhã (Desenvolvimento) | **Laboratório:** Roteamento declarativo + upstreams e verificações de integridade |
| **09h50 - 10h05** | - | *Coffe Break* |
| **10h05 - 11h20** | Amanhã (Desenvolvimento) | **Laboratório:** Catálogo de APIs e OAS + Transformações |
| **11h20 - 12h00** | Amanhã (Desenvolvimento) | **Laboratórios Avançados:** Roteamento Inteligente e Validação JSON |
| **12h00 - 13h00** | - | *Almoço (saída dos desenvolvedores / entrada das operações)* |
| **13h00 - 13h15** | Tarde (Todos) | Boas-vindas e sincronização de ambientes (Participantes da Tarde) |
| **13h15 - 14h15** | Tarde (Ops) | **Laboratório:** Observabilidade distribuída com OTel, OpenObserve e Phoenix |
| **14h15 - 15h25** | Tarde (seg) | **Laboratório:** Autenticação de chave Zero Trust + OIDC e ACL |
| **15h25 - 15h40** | - | *Coffe Break* |
| **15h40 - 16h25** | Tarde (seg) | **Laboratório:** Restrição de IP + Autorização OPA |
| **16h25 - 17h00** | Tarde (Todos) | Encerramento do workshop, resolução de dúvidas e próximos passos |
