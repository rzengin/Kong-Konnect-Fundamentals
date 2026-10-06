KONG

Pré-requisitos de instalação

Oficina Kong Konnect

Guia simples para preparar a estação de trabalho do aluno

| Campo | Detalhe |
|---|---|
| Fornecedor | KONG |
| Plataforma | Kong Konnect - arquitetura híbrida com Control Plane SaaS e ambientes de laboratório local |
| Objetivo | Indique o que cada aluno deve instalar, o que deve ser configurado no Konnect e qual conectividade deve ter desde sua estação de trabalho. |
| Versão | 0,4 |
| Data | 26 de agosto de 2026 |

Importante: Não inclua tokens Konnect reais em documentos, e-mails,
tickets ou repositórios. Cada aluno deve usar seu próprio PAT ou token
temporário dado pelo instrutor.

1\. Objetivo deste documento

Este documento resume, de forma prática, o que cada aluno deve ter
pronto antes do workshop Kong Konnect. O foco é preparar o laptop
para executar exercícios locais, gerenciar configurações declarativas
com deck, importar coleções para o Insomnia, configurar serviços
laboratório com Docker e validar a conexão com a instância Kong
Konnect atribuído.

O documento não substitui as orientações laboratoriais. Seu propósito é
servir como checklist prévio para evitar que o horário do workshop seja
consumir instalando ferramentas básicas ou resolvendo falhas de rede.

# 2. Lista de verificação mínima antes do workshop

| **Categoria** | **Requisito (versão mínima)** | **Uso em exercícios** |
|---|---|---|
| Sistema operacional | macOS, Linux ou Windows (CMD) | Execute CLI, Docker, scripts e testes locais. |
| Docker | Docker Desktop ou Docker Engine (v20.10+) com Docker Compose (v2.x) | Construa Kong Data Plane local, mocks, Keycloak, WireMock, Prism e pilha de observabilidade. |
| Git | Cliente Git instalado (v2.20+) | Clone ou receba o repositório de ativos do workshop. |
| ondular | curl CLI disponível (v7.0+) | Teste APIs, Konnect, simulações e endpoints locais. |
| jq | Processador JSON de linha de comando (v1.6+) | Leia respostas JSON de APIs e scripts. |
| convés | deck CLI (v1.65+) ou versão indicada pelo instrutor | Sincronize serviços, rotas, plugins e consumidores com o Konnect. |
| Insônia | Aplicativo de desktop Insônia (v8.0+) | Importe coleções, OpenAPI e execute testes manuais ou Runner. |
| Terraforma | Terraform CLI (v1.5+), necessária para exercícios APIOps/Portal/Catalog | Gerencie os recursos da plataforma quando o laboratório os incluir. |
| Node.js/npm/inso | Node.js LTS (v18+) e, se aplicável, Insomnia CLI | Execute testes através do terminal com utilitários inso e de suporte. |
| Editora | VS Code ou outro editor de texto | Edite YAML, OpenAPI, .env e scripts. |

#3. Instalação por sistema operacional

### 3.1 Windows (CMD)

Se você usa Windows e pretende executar o workshop a partir da linha de comando `cmd.exe`:

- **Docker:** instale o [Docker Desktop para Windows](https://docs.docker.com/desktop/setup/install/windows-install/).
- **Git e curl:** Eles geralmente estão incluídos no Windows 10/11. Você pode instalar o Git baixando-o em [git-scm.com](https://git-scm.com/).
- **decK CLI:** Você pode instalá-lo via `winget` ou baixando o binário:  

```cmd
  winget install Kong.decK
  

```
- **jq:** Você pode instalá-lo via `winget`:  

```cmd
  winget install jqlang.jq
  

```
- **Terraforma:**  

```cmd
  winget install Hashicorp.Terraform
  

```
### 3.2 macOS (Intel ou Apple Silicon)

As instruções a seguir são práticas. Se KONG usar
empacotadores corporativos, Intune, SCCM, Jamf, repositórios internos ou
restrições de software, use o mecanismo corporativo equivalente e
em seguida, execute as validações na seção 6.

## 3.1 macOS

Opção recomendada: Homebrew para ferramentas CLI e
baixe/instale Docker Desktop e Insomnia. Abra o Terminal e
execute:

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
Depois de instalar o Docker Desktop:

1. Abra o Docker Desktop em Aplicativos.

2. Aceite os termos de uso do Docker Desktop de acordo com a política
  KONG.

3. Em Configurações \> Recursos aloque pelo menos 4 GB de memória se o
  laptop permite isso. A stack de observabilidade (Módulo 06 / Lab 07:
  OTel Collector + OpenObserve + Arize Phoenix) consome ~1,2 GB desse
  total; os ~4 GB adicionais da plataforma anterior não são mais necessários.

4. Aguarde até que o Docker indique o status Em execução.

Validação rápida no macOS:

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
## 3.3Linux

As instruções a seguir cobrem Ubuntu/Debian. Para Fedora/RHEL,
use pacotes dnf e rpm equivalentes. No Linux você pode usar Docker
Desktop ou Docker Engine; para o workshop, Docker Engine com Docker
Compor geralmente é suficiente.

### 3.3.1 Ubuntu/Debian - ferramentas básicas

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release git 
unzip python3 python3-pip
```
### 3.3.2 Ubuntu/Debian - Docker Engine e Docker Compose

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
### 3.3.5 Ubuntu/Debian - deck

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
### 3.3.6 Ubuntu/Debian - Insônia

Baixe o pacote Linux do site oficial da Insomnia. Se
baixe um .deb, instale-o assim na pasta Downloads:

```bash
cd ~/Downloads
sudo apt install ./Insomnia\*.deb
```
Validação rápida no Linux:

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
#4. Configurações necessárias no Kong Konnect

Cada aluno deve ter acesso à organização Konnect utilizada no
workshop e o Plano de Controle atribuído para os exercícios. O instrutor
ou administrador da plataforma deve validar esses pontos antes
começar.

| **Elemento** | **Deve estar pronto** | **Validação esperada** |
|---|---|---|
| Conta Konnect | Usuário convidado com acesso à organização do workshop. | O aluno pode fazer login no Konnect. |
| Plano de controle | Plano de controle disponível para exercícios. Para este guia: `your_MockAPI_name` | O aluno pode ver o Plano de Controle no Konnect. |
| Permissões | Permissões suficientes para ler Data Plane Nodes e gerenciar serviços, rotas, plugins, consumidores e credenciais de acordo com o laboratório. | O aluno pode executar ping do deck gateway e sincronizar a configuração se o exercício assim o exigir. |
| Token de acesso pessoal | PAT pessoal ou token temporário fornecido pelo instrutor. Não deve ser compartilhado ou documentado. | O token permite a conexão do deck ao Konnect. |
| Plano de dados locais | Ativos, certificados ou docker-compose fornecidos pelo instrutor se o aluno precisar construir seu próprio plano de dados. | No Konnect, o Plano de Dados deve aparecer conectado e, quando aplicável, no estado Em Sincronização. |

## 4.1 Variáveis de ambiente

Utilize os valores definidos para o workshop. O token real deve ser
inseridos por cada aluno em sua própria estação de trabalho.

```bash
# macOS / Linux / Codespaces
export KONNECT_TOKEN="<PAT_PERSONAL_O_TOKEN_TEMPORAL>"
export DEMO_PREFIX="tu_nombre"
export KONNECT_CONTROL_PLANE_NAME="${DEMO_PREFIX}_MockAPI"
export CONTROL_PLANE_NAME="$KONNECT_CONTROL_PLANE_NAME"
export KONNECT_ADDR="https://us.api.konghq.com"
```
## 4.2 Arquivo .deck.yaml

Se o repositório do workshop incluir um script de configuração, use-o
roteiro. Se você precisar criar o arquivo manualmente, na pasta
do laboratório:

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
#5. Conectividade necessária da estação de trabalho

Antes do workshop, valide se a rede corporativa, VPN, proxy,
antivírus e firewall local não bloqueiam a comunicação necessária. Sim
KONG usa inspeção TLS, pode ser necessário permitir exceções para
Domínios Konnect e repositórios de software.

| Destino / Porto | Uso | Requisito |
|------------------|-----|-----------|
| `https://us.api.konghq.com:443` | API Konnect usada por deck e scripts. | Saída HTTPS permitida no laptop. |
| Domínios de tempo de execução Konnect / `*.konghq.com:443` | Conexão do Plano de Dados local com o Plano de Controle SaaS. | Saída TLS permitida; evite quebras pela inspeção TLS. |
| `github.com` / `releases.githubusercontent.com:443` | Baixe deck, ativos e dependências. | Saída HTTPS permitida. |
| `registry-1.docker.io` / `auth.docker.io` / Docker Hub:443 | Baixe imagens do Docker do laboratório. | Saída HTTPS permitida; autenticar se a rede tiver limites de taxa. |
| `npmjs.org` / `nodejs.org` / `deb.nodesource.com:443` | Node.js, npm e inso CLI quando aplicável. | Saída HTTPS permitida. |
| `releases.hashicorp.com` / `apt.releases.hashicorp.com:443` | Instalação do Terraform. | Saída HTTPS permitida. |
| `github.com/Kong/terraform-provider-konnect:443` | Baixando o provedor kong/konnect. | Saída HTTPS permitida. |
| `insomnia.rest` / lançamentos do GitHub:443 | Baixar insônia. | Saída HTTPS permitida. |

## 5.1 Portas locais que devem estar livres

Os exercícios podem levantar vários recipientes locais. Antes
iniciar, fechar serviços que estão usando essas portas ou solicitar o
variáveis alternativas do instrutor.

| Porto local | Serviço típico | Utilização em laboratório |
|------------|----------------|------|
| 8.000 | Proxy Kong | Entrada principal para testar APIs expostas pelo Kong. |
| 8010 | Segundo plano de dados opcional | Exercício de clustering/escalabilidade. |
| 8080 | Simulação de prisma | Simulação de API baseada em OpenAPI. |
| 9081 | back-end httpbin | Eco de backend para validar cabeçalhos, corpos e transformações. |
| 8082 | WireMock | Simulação de APIs de negócios. |
| 8083 | Capa de chave | Servidor OIDC local para exercícios de autenticação. |
| 8100 | Métricas Kong | Endpoint local de métricas do Prometheus. |
| 5080 | OpenObserve | UI de observabilidade: traces, métricas, logs e dashboards (Módulo 06 / Lab 07). |
| 6006 | Arize Phoenix | UI de traces orientada a LLM / IA (Módulo 06 / Lab 07). |
| 4317/4318 | OpenTelemetry Collector | Recepção OTLP gRPC/HTTP de traces, métricas e logs. |
| 13133 | OpenTelemetry Collector | Health check (somente `127.0.0.1`). |
| 9092 | Kafka | Corretor de testes do Event Gateway (Laboratório 12). |

#6. Validação antes do workshop

Execute esta validação pelo menos um dia antes do workshop. Se falhar
qualquer ponto, levante-o como uma trava operacional.

## 6.1 Validar ferramentas locais

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
## 6.3 Validar conectividade com Konnect

```bash
curl -I https://us.api.konghq.com

deck gateway ping
```
## 6.4 Validar o plano de dados local quando estiver ativo

```bash
curl -i http://localhost:8000/qualquer-rota
```
```bash
# Respuesta esperada si Kong está activo pero sin rutas:
# HTTP/1.1 404 Not Found
# {"message":"no Route matched with those values"}
```
#7. Problemas comuns e solução rápida

| **Sintoma** | **Causa provável** | **Ação sugerida** |
|---|---|---|
| docker: comando não encontrado | Docker não instalado ou PATH não atualizado. | Abra o novo terminal e verifique a instalação. |
| Não é possível conectar-se ao daemon Docker | O Docker Desktop não foi iniciado ou o usuário não pertence ao grupo docker no Linux. | Inicie o Docker Desktop. No Linux execute `usermod -aG docker $USER` e reabra a sessão. |
| ping do gateway do deck falha com 401/403 | PAT inválido, expirado ou sem permissões. | Gere novamente o PAT ou valide as permissões no Konnect. |
| ping do gateway do deck não resolve DNS ou tempo limite | Proxy, VPN, DNS ou firewall bloqueiam a saída para o Konnect. | Valide a saída HTTPS para os domínios de tempo de execução us.api.konghq.com e Konnect. |
| Porto local movimentado | Outro processo usa a porta necessária. | Identifique o processo e a porta de liberação ou peça ao instrutor uma variável alternativa. |
| Docker não baixa imagens | Bloqueio Docker Hub, proxy não configurado ou limite de taxa. | Configure o proxy corporativo no Docker Desktop ou use o espelho corporativo. |
| Insônia não importa coleção | Arquivo incorreto ou versão desatualizada. | Atualize o Insomnia e reimporte o espaço de trabalho entregue. |
| inicialização do terraform falha com erro 403/timeout | A restrição de rede ou proxy impede o download do provedor. | Execute a instalação offline do provedor (consulte a Seção 7.1). |



# 8. Referências oficiais para instalação

Essas referências estão incluídas para estudantes que precisam validar
compatibilidade, versões atuais ou instruções alternativas para
instalação.

- Docker Desktop: https://docs.docker.com/desktop/

- Docker Desktop para macOS:
 https://docs.docker.com/desktop/setup/install/mac-install/



- Docker Desktop para Linux:
 https://docs.docker.com/desktop/setup/install/linux/

- Kong deck: https://developer.konghq.com/deck/

- Insônia: https://insomnia.rest/

- Terraform: https://developer.hashicorp.com/terraform/install

-Node.js/npm:
https://docs.npmjs.com/downloading-and-installing-node-js-and-npm/
