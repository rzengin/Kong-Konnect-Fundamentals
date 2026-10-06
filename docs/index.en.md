# Kong API Gateway & Konnect Workshop

Welcome to the official workshop material for **Kong API Gateway & Konnect**.
This **four-day** in-person course is designed to provide practical training in API Gateway, AI Gateway, GitOps, Security, and Observability: **Day 1** combines theory and demos, **Day 2** is dedicated to hands-on labs, **Day 3** introduces **Kong AI Gateway** with theory and demos, and **Day 4** is dedicated to hands-on AI Gateway labs.

![Kong Konnect Overview](./public/konnect_unified_api_platform.png)

---

## Description and Objectives

The entire workshop uses a **GitOps** approach with declarative management via **decK** (Days 1–2) and **kongctl** (AI Gateway, Days 3–4), automation with **Terraform**, and simulated backends with Docker.

### Test Backend: httpbin
As the common thread for our practices and demonstrations, we will use **httpbin** as our simulated test backend. In our local environment, this service is already pre-deployed via Docker (in the `httpbin-backend` container). `httpbin` is a widely used generic tool for testing HTTP requests; it allows us to easily verify which headers, methods, and message bodies are effectively reaching the backend after passing through the API Gateway.

Our work during the workshop will be to expose, secure, and manage traffic to these test APIs using Kong Konnect, allowing us to focus on routing, transformations, and security policies without relying on complex business logic in the backend.

### Day 1: Theoretical Block — Fundamentals, Operations, and Security
**Comprehensive Kong Konnect Theory**

- **Conceptual Architecture**: Understanding the separation of Control Plane (Konnect) and Data Plane (Kong Gateway based on NGINX/OpenResty), and communication via gRPC mTLS tunnel.
- **Developer Track**: Concepts of Gateway Services, Routes, Plugins, Developer Portal, and publishing Catalog APIs.
- **Operations Track**: Declarative governance with decK/Terraform, traffic monitoring, and advanced observability with OpenTelemetry (OpenObserve + Arize Phoenix).
- **Security Track**: Zero Trust strategies, OIDC, RBAC, and access control using OPA.
- **Complementary demos**: ITSM integration, Secrets Management (Vaults) and OWASP / WAF security.

### Day 2: Practical Block — Hands-On Labs
**Guided Labs and Practice**

- **Setup and Routing**: Local environment initialization and declarative route deployment.
- **Plugins and Portals**: Payload transformations, intelligent routing, and OAS catalog publishing.
- **Operations and Security**: Local observability deployment (OTel Collector + OpenObserve + Phoenix), Key Auth application, IP restriction, and OIDC.
- **Event Gateway**: Asynchronous integration by sending messages to Kafka topics (Event-Driven Architecture).

### Day 3: AI Gateway — Theory and Demonstrations
**Kong AI Gateway 2.2 on Konnect, governed with kongctl**

- **2.x architecture**: dedicated Control Plane in Konnect (models, providers, policies, MCP, agents), `kong/kong-ai-gateway:2.2.0` Data Plane and APIOps with kongctl.
- **Access and governance**: one OpenAI-compatible endpoint for local and commercial models, failover, passthrough, per-model ACLs, token quotas and USD budgets.
- **Security and optimization**: guardrails (regex and semantic), PII, semantic routing, semantic caching, compression and managed RAG.
- **Agents**: REST APIs as MCP tools with per-agent ACLs, A2A, AI observability (OpenObserve + Phoenix), FinOps and Metering & Billing; AI Summit 2026 announcements.

### Day 4: AI Gateway — Hands-On Labs
**Every participant builds their own AI Gateway, with no paid API keys**

- **Setup**: AI Gateway in Konnect + 2.2 Data Plane on Docker + Ollama with small open-weight models (CPU).
- **Labs**: multi-LLM and failover, quotas and budget, guardrails, semantics and caching, RAG, MCP, A2A, observability.
- **Final challenge**: governed credit assistant (banking).

---

## Full Workshop Agenda

The workshop is planned over four structured days: Days 1 and 2 from **08:00 to 17:00**, and Days 3 and 4 (AI Gateway) from **08:00 to 16:30**:

### Day 1: Theory and Demonstrations
| Time | Block | Topic / Module |
|---------|--------|---------------|
| **08:00 - 08:30** | Morning (All) | Welcome, Architecture, and Conceptual Setup |
| **08:30 - 09:15** | Morning (Dev) | Module 00: Conceptual Architecture and Local Setup |
| **09:15 - 10:15** | Morning (Dev) | Module 01: Kong Konnect Gateway & Control Planes |
| **10:15 - 10:30** | - | *Coffee Break* |
| **10:30 - 12:00** | Morning (Dev) | Module 02: Kong Plugins Ecosystem |
| **12:00 - 13:00** | Morning (Dev) | Module 03: Developer Portal, Customization, and Onboarding |
| **13:00 - 14:15** | - | *Lunch (Devs depart)* |
| **14:15 - 15:15** | Afternoon (Ops) | Module 04: Gateway Operations & GitOps (decK / Terraform) |
| **15:15 - 15:45** | Afternoon (Ops) | Module 05: Monitoring and Logging (Konnect Analytics) |
| **15:45 - 16:00** | - | *Coffee Break* |
| **16:00 - 16:45** | Afternoon (Ops) | Module 06: Advanced Observability (OpenTelemetry / OpenObserve / Phoenix) |
| **16:45 - 17:30** | Afternoon (Sec) | Module 07: Securing API Traffic (Key Auth, ACL, OIDC, IP Restriction) |
| **17:30 - 17:45** | Afternoon (All) | **Environment Health Check** (Day 2 Preparation) |

### Day 2: Practical — Hands-On Labs and Closing
| Time | Block | Lab / Practical Activity |
|---------|--------|----------------------------------|
| **08:00 - 08:15** | Morning (All) | Welcome to Practical Day, credentials, and GitOps review |
| **08:15 - 09:00** | Morning (Dev) | **Lab:** Local Environment Setup |
| **09:00 - 09:50** | Morning (Dev) | **Lab:** Declarative Routing + Upstreams & Health Checks |
| **09:50 - 10:05** | - | *Coffee Break* |
| **10:05 - 11:20** | Morning (Dev) | **Lab:** Catalog APIs & OAS + Transformations |
| **11:20 - 12:00** | Morning (Dev) | **Advanced Labs:** Intelligent Routing and JSON Validation |
| **12:00 - 13:00** | - | *Lunch (Devs depart / Ops arrive)* |
| **13:00 - 13:15** | Afternoon (All) | Welcome and environment synchronization (Afternoon arrivals) |
| **13:15 - 14:15** | Afternoon (Ops) | **Lab:** Distributed Observability with OTel, OpenObserve, and Phoenix |
| **14:15 - 15:25** | Afternoon (Sec) | **Lab:** Zero Trust Key Auth + OIDC & ACL |
| **15:25 - 15:40** | - | *Coffee Break* |
| **15:40 - 16:25** | Afternoon (Sec) | **Lab:** IP Restriction + OPA Authorization |
| **16:25 - 17:00** | Afternoon (All) | Workshop closing, Q&A, and next steps |

### Day 3: AI Gateway — Theory and Demonstrations
| Time | Block | Topic / Module |
|---------|--------|---------------|
| **08:00 - 08:15** | Morning (All) | Welcome and goals of the AI block |
| **08:15 - 09:00** | Morning (Dev) | AI Module 00: AI Gateway 2.x Architecture on Konnect and kongctl |
| **09:00 - 09:45** | Morning (Dev) | AI Module 01: One endpoint, many LLMs |
| **09:45 - 10:00** | - | *Coffee Break* |
| **10:00 - 10:45** | Morning (Sec) | AI Module 02: Governance, token quotas and budget |
| **10:45 - 11:30** | Morning (Sec) | AI Module 03: Guardrails and PII |
| **11:30 - 12:10** | Morning (Dev) | AI Module 04: Semantic routing, caching and compression |
| **12:10 - 13:10** | - | *Lunch* |
| **13:10 - 13:35** | Afternoon (Dev) | AI Module 05: Managed RAG |
| **13:35 - 14:25** | Afternoon (Dev) | AI Module 06: MCP — APIs as tools, bundling and per-agent ACLs |
| **14:25 - 14:50** | Afternoon (Dev) | AI Module 07: Agents and A2A |
| **14:50 - 15:05** | - | *Coffee Break* |
| **15:05 - 15:50** | Afternoon (Ops) | AI Module 08: AI Observability and FinOps, Metering & Billing |
| **15:50 - 16:10** | Afternoon (All) | AI Module 09: AI Summit 2026 announcements and roadmap |
| **16:10 - 16:30** | Afternoon (All) | **Environment Health Check** for Day 4 (kongctl ≥ 1.20.1, Docker, model downloads) |

### Day 4: AI Gateway — Hands-On Labs
| Time | Block | Lab |
|---------|--------|-------------|
| **08:00 - 08:45** | Morning (All) | **AI Lab 00:** AI Gateway Setup (Konnect + DP 2.2 + Ollama) |
| **08:45 - 09:20** | Morning (Dev) | **AI Lab 01:** Multi-LLM, failover and passthrough |
| **09:20 - 10:00** | Morning (Sec) | **AI Lab 02:** Governance: ACLs, quotas and budget |
| **10:00 - 10:15** | - | *Coffee Break* |
| **10:15 - 10:50** | Morning (Sec) | **AI Lab 03:** Guardrails |
| **10:50 - 11:25** | Morning (Dev) | **AI Lab 04:** Semantic routing and caching |
| **11:25 - 11:55** | Morning (Dev) | **AI Lab 05:** RAG |
| **11:55 - 12:55** | - | *Lunch* |
| **12:55 - 13:40** | Afternoon (Dev) | **AI Lab 06:** MCP |
| **13:40 - 14:05** | Afternoon (Dev) | **AI Lab 07:** A2A |
| **14:05 - 14:50** | Afternoon (Ops) | **AI Lab 08:** AI Observability (OpenObserve + Phoenix) |
| **14:50 - 15:05** | - | *Coffee Break* |
| **15:05 - 15:50** | Afternoon (All) | **AI Challenge (optional):** Governed credit assistant |
| **15:50 - 16:15** | Afternoon (All) | Course closing, environment cleanup (`aplicar.sh 00`, `teardown.sh --all`) and next steps |

!!! note "Optional content"
    The complementary Day 1 demos (ITSM, Secrets, OWASP / WAF) and Lab 12 (Event Gateway with Kafka) are not part of the base agenda: they are scheduled depending on the available time and the audience profile.
