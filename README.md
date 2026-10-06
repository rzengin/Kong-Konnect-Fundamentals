<div align="center">
  <h1>Kong Konnect Fundamentals</h1>
  <h2>Workshop Kong API Gateway &amp; Konnect</h2>
  <p><strong>Formación práctica en API Gateway, GitOps, Seguridad y Observabilidad</strong></p>
  <p><em>Día 1: teoría y demos · Día 2: laboratorios hands-on · Días 3–4 (AI Gateway): próximamente</em></p>
</div>

---

> **Nota histórica:** la entrega del curso a STP (septiembre 2026) se conserva en el tag [`v2026-09-stp`](https://github.com/rzengin/Kong-Training-STP/releases/tag/v2026-09-stp) del repositorio anterior `rzengin/Kong-Training-STP` (privado). Este repositorio arranca con un historial limpio. Ver [RELEASES.md](RELEASES.md).

## Descripción

Este repositorio contiene el material del **workshop Kong API Gateway & Konnect** y el sitio de documentación que usan los asistentes:

👉 **Sitio publicado:** [https://rzengin.github.io/Kong-Konnect-Fundamentals/](https://rzengin.github.io/Kong-Konnect-Fundamentals/) (español, English, Português)

- **Día 1 — Teoría y demos** (Devs, Ops y Sec): arquitectura Control Plane / Data Plane, Gateway Services y Routes, plugins, Developer Portal, operaciones con decK/Terraform, monitoreo, observabilidad con OpenTelemetry (OpenObserve + Arize Phoenix) y seguridad (Key Auth, ACL, OIDC, IP Restriction, OPA). Demos complementarias: integración ITSM, gestión de secretos y OWASP / WAF.
- **Día 2 — Laboratorios**: setup local, routing declarativo, upstreams y health checks, Catalog APIs & OAS, transformaciones, ruteo inteligente, validación JSON, observabilidad, Zero Trust, OIDC & ACL, restricción de IPs, OPA y Event Gateway con Kafka.
- **Días 3–4 — AI Gateway**: en preparación; se integrarán en una próxima versión del sitio.

Todo el workshop usa un enfoque **GitOps** con gestión declarativa vía **decK**, automatización con **Terraform** y backends simulados con Docker.

---

## Estructura del proyecto

```text
Kong-Konnect-Fundamentals/
├── README.md                     ← Este archivo
├── RELEASES.md                   ← Convención de tags por entrega
├── mkdocs.yml                    ← Configuración del sitio (MkDocs Material + i18n es/en/pt)
├── requirements-docs.txt         ← Dependencias para construir el sitio
├── attendees.example.csv         ← Formato del CSV de asistentes (datos ficticios)
├── .devcontainer/                ← Entorno GitHub Codespaces / Dev Container
├── .github/
│   ├── workflows/deploy-docs.yml ← CI: build estricto + chequeo de enlaces + deploy a GitHub Pages
│   └── ISSUE_TEMPLATE/           ← Formulario de evaluación del curso
├── docs/                         ← Fuente del sitio (cada página en .md / .en.md / .pt.md)
│   ├── index.md                  ← Portada y agenda
│   ├── 00-setup-entorno/         ← Prerrequisitos, red, docker-compose, Terraform y scripts de setup
│   ├── dia-1-teoria-y-demos/     ← Módulos 00–07 y demos 08–10 del Día 1
│   ├── dia-2-labs/               ← Labs 00–12 del Día 2
│   ├── Evaluacion_del_Curso.md
│   ├── public/ · assets/         ← Imágenes y logos
│   └── extra.css
├── workshop-assets/              ← Archivos de decK, docker-compose y scripts usados en demos y labs
│   ├── dia-1/
│   └── dia-2/
├── scripts/                      ← Alta de asistentes, traducción, guías Windows, Mermaid
├── run_all_demos.sh              ← Validación automatizada de las demos del Día 1
└── run_all_labs.sh               ← Validación automatizada de los labs del Día 2
```

---

## Agenda resumida

| Día | Mañana | Tarde |
|-----|--------|-------|
| **Día 1 — Teoría y demos** | Developer track: Módulos 00–03 (arquitectura, Konnect Gateway, plugins, Developer Portal) | Ops & Sec tracks: Módulos 04–07 (IaC, monitoring, observabilidad, securing API traffic) |
| **Día 2 — Labs** | Labs de desarrollo 00–06 | Labs de operaciones y seguridad 07–11 (+ Lab 12 Event Gateway opcional) |

La agenda detallada por horario está en la [portada del sitio](https://rzengin.github.io/Kong-Konnect-Fundamentals/).

---

## Preparar el entorno del asistente

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/rzengin/Kong-Konnect-Fundamentals?quickstart=1)

**Camino A — GitHub Codespaces (recomendado).** Un clic en el botón crea un entorno Linux en la nube con Docker (docker-in-docker), decK, kongctl, inso, Terraform, Node.js, Python y jq: el `postCreateCommand` del [devcontainer](.devcontainer/devcontainer.json) ejecuta `docs/00-setup-entorno/scripts/install_prereqs.sh`. Evita las restricciones habituales de laptops corporativas (Docker Desktop bloqueado o sin licencia, Windows sin WSL2, proxies, permisos de administrador). Los puertos del laboratorio se reenvían automáticamente: 8000/8443 (proxy Kong), 8001, 5080 (OpenObserve), 6006 (Phoenix) y 4318 (OTLP). Se recomienda una máquina de 4 núcleos / 8 GB. `KONNECT_TOKEN` y `DEMO_PREFIX` se pueden definir como [secretos de Codespaces](https://github.com/settings/codespaces).

**Camino B — Instalación local.** Ver la guía [Prerrequisitos de Instalación](docs/00-setup-entorno/Prerequisitos_Workshop_Kong_Konnect_Instalacion.md). En resumen:

```bash
git clone https://github.com/rzengin/Kong-Konnect-Fundamentals.git
cd Kong-Konnect-Fundamentals
bash docs/00-setup-entorno/scripts/install_prereqs.sh   # decK, kongctl, inso, jq, Terraform... (Linux/macOS)
```

En ambos caminos:

```bash
export KONNECT_TOKEN="kpat_..."   # PAT de Konnect entregado por el instructor
export DEMO_PREFIX="tu_nombre"
```

Luego seguir el [Lab 00 — Setup Local](docs/dia-2-labs/Lab_00_Setup_Local.md).

> **Credenciales de OpenObserve:** no hay contraseña por defecto. `workshop-assets/dia-1/06-observability/scripts/setup-observability.sh` genera en la primera ejecución `otel-stack/.env` (contraseña aleatoria, `chmod 600`, fuera de git), imprime el login al final y lo vuelve a mostrar con `setup-observability.sh status`. El email es configurable con `ZO_ROOT_USER_EMAIL`.

---

## Para instructores

### Alta de asistentes en Konnect (`scripts/onboard_attendees.py`)

Crea (o reutiliza) un team de Konnect para la capacitación, le asigna roles, invita a la organización a quien aún no es usuario y agrega a todos al team. Solo usa la biblioteca estándar de Python.

1. Preparar un CSV con columnas `name,email,company[,role]` (ver [`attendees.example.csv`](attendees.example.csv), datos ficticios). Guardarlo como `attendees-<cliente>.csv` en la raíz o fuera del repo: **`attendees*.csv` está en `.gitignore`** (salvo el ejemplo) porque contiene datos personales.
2. Cargar las credenciales de la organización de Konnect en el entorno (`kong-env`): `KONNECT_TOKEN` (token con permisos de administración de la organización) y `KONNECT_ADDR` (ej. `https://us.api.konghq.com`). Si falta alguna, el script termina con error. El token nunca se imprime.
3. Revisar el plan (modo **dry-run por defecto**: solo consultas GET) y luego aplicarlo:

```bash
python3 scripts/onboard_attendees.py attendees-acme.csv --team training-2026-11-acme            # dry-run
python3 scripts/onboard_attendees.py attendees-acme.csv --team training-2026-11-acme --apply    # ejecuta
```

Opciones: `--role 'Control Planes:Viewer'` (repetible; ese es el default), `--entity-id` (default `*`), `--region` (default: deducida de `KONNECT_ADDR`), `--api-version v2|v3` (default `v3`). Es idempotente: volver a correrlo después de que los asistentes acepten la invitación agrega al team a quienes quedaron pendientes.

### Entregas

Al terminar cada entrega, crear el tag `vAAAA-MM-<cliente>` según [RELEASES.md](RELEASES.md).

### Validación del material

`run_all_demos.sh` y `run_all_labs.sh` recorren las demos del Día 1 y los labs del Día 2 contra un Control Plane real (requieren `KONNECT_TOKEN` y `DEMO_PREFIX`).

---

## Documentación (MkDocs)

El sitio se construye con **MkDocs Material** y **mkdocs-static-i18n** (estructura por sufijo: `pagina.md` = español, `pagina.en.md` = inglés, `pagina.pt.md` = portugués). Al editar una página, mantener sincronizadas las tres variantes.

### Levantar el sitio localmente

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements-docs.txt
mkdocs serve                 # http://127.0.0.1:8000
mkdocs build --strict        # mismo chequeo que CI
```

### Publicación

El workflow [`.github/workflows/deploy-docs.yml`](.github/workflows/deploy-docs.yml) se ejecuta en cada push y pull request a `main`:

1. `mkdocs build --strict` (incluye validación de enlaces y anclas internas de MkDocs).
2. Chequeo offline de enlaces internos y anclas del sitio generado con [lychee](https://github.com/lycheeverse/lychee).
3. Solo en push a `main` y si ambos pasan: `mkdocs gh-deploy` a la rama `gh-pages` (GitHub Pages).

En pull requests se ejecutan únicamente los chequeos.

### Traducciones

`scripts/translate_docs.py` genera las variantes `.en.md` / `.pt.md` a partir de la página en español usando Gemini. La API key se lee de la variable de entorno `GEMINI_API_KEY` (definida por `kong-env`); nunca se guarda en el repo.

```bash
pip install google-genai
export GEMINI_API_KEY=...          # o ejecutar kong-env
python scripts/translate_docs.py --lang en                    # páginas sin traducción al inglés
python scripts/translate_docs.py --lang pt docs/index.md      # una página concreta
python scripts/translate_docs.py --lang en --force docs/...   # regenerar una traducción existente
```

Revisar siempre el resultado (bloques de código, rutas, encabezados) antes de commitear.

### Otras utilidades (`scripts/`)

| Script | Uso |
|--------|-----|
| `scripts/onboard_attendees.py` | Alta de asistentes en Konnect (ver [Para instructores](#para-instructores)). |
| `scripts/translate_docs.py` | Traducciones es → en/pt con Gemini (ver arriba). |
| `scripts/generate_windows_guides.py` | Genera versiones Windows-only de las guías y sus PDFs. |
| `scripts/preprocess_mermaid.py` | Reemplaza bloques Mermaid por PNG (para exportar a PDF). |

---

## Tecnologías utilizadas

| Herramienta | Versión | Uso |
|-------------|---------|-----|
| Kong Gateway Enterprise | 3.15.x | API Gateway (Data Plane) |
| Kong Konnect | SaaS | Control Plane en la nube |
| decK | 1.65+ | Gestión declarativa (GitOps) |
| Terraform | 1.5+ | IaC para Control Planes y Teams |
| OpenTelemetry Collector (contrib) | 0.161.0 | Recepción OTLP y reparto de telemetría |
| OpenObserve | v1.0.4 | Observabilidad (trazas, métricas, logs, dashboards) |
| Arize Phoenix | 20.19.0 | Vista de trazas orientada a LLM / IA |
| Docker | 24+ | Contenedores locales |
| MkDocs Material + mkdocs-static-i18n | — | Sitio de documentación multilenguaje |
