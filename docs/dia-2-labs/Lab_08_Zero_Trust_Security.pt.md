#Laboratório 08: Segurança Zero Trust (Chave, Autenticação Básica, JWT e HMAC)

O modelo de segurança **Zero Trust** é baseado em um princípio fundamental: *"Nunca confie, sempre verifique"*. Não importa se uma solicitação vem da Internet pública, de um sistema legado interno ou de um microsserviço moderno dentro da mesma VPC; O API Gateway bloqueará todo o tráfego por padrão, a menos que uma credencial criptográfica válida seja apresentada.

Neste laboratório vamos proteger 4 serviços diferentes simulando as arquiteturas mais comuns em uma empresa, forçando a autenticação dos consumidores.

```mermaid
flowchart LR
  classDef client fill:#f8fafc,stroke:#64748b,stroke-width:2px,color:#0f172a,rx:5,ry:5;
  classDef kong fill:#d1fae5,stroke:#059669,stroke-width:2px,color:#064e3b,rx:10,ry:10;
  classDef target fill:#f1f5f9,stroke:#475569,stroke-width:2px,color:#0f172a,rx:5,ry:5;
  classDef plugin fill:#ccfbf1,stroke:#0d9488,stroke-width:2px,color:#115e59;
  classDef cache fill:#eff6ff,stroke:#2563eb,stroke-width:1px,color:#1e3a8a,rx:5,ry:5;

  C1(["Partner App<br/>(Internet)"]):::client
  C2(["Legacy App<br/>(Internal)"]):::client
  C3(["Microservice<br/>(Internal VPC)"]):::client
  C4(["Banco B<br/>(B2B Integrations)"]):::client
  
  subgraph Gateway ["Kong Data Plane"]
    P1{"Plugin<br/>(key-auth)"}:::plugin
    P2{"Plugin<br/>(basic-auth)"}:::plugin
    P3{"Plugin<br/>(jwt)"}:::plugin
    P4{"Plugin<br/>(hmac-auth)"}:::plugin
    Cache[("Local Cache<br/>(Consumers & Keys)")]:::cache
    
    P1 -. "Valida Key" .- Cache
    P2 -. "Valida User/Pass" .- Cache
    P3 -. "Valida Firma" .- Cache
    P4 -. "Recalcula y Valida Hash" .- Cache
  end
  Gateway:::kong

  B1["Upstream<br/>(Public API)"]:::target
  B2["Upstream<br/>(Legacy API)"]:::target
  B3["Upstream<br/>(Internal API)"]:::target
  B4["Upstream<br/>(B2B API)"]:::target

  C1 -- "apikey: X" --> P1
  C2 -- "Basic base64" --> P2
  C3 -- "Bearer <JWT>" --> P3
  C4 -- "Signature: <Hash>" --> P4

  P1 -- "Válido" --> B1
  P2 -- "Válido" --> B2
  P3 -- "Válido" --> B3
  P4 -- "Válido" --> B4
```
## Objetivos

- Configure os plugins `key-auth`, `basic-auth`, `jwt` e `hmac-auth` no nível de serviço.
- Criar `Consumidores` (Aplicações) declarativamente com suas respectivas credenciais.
- Valide que nenhuma rota permite tráfego anônimo.
- Compreender a diferença entre enviar um segredo pela rede e enviar uma assinatura matemática (HMAC).

---

## Etapa 1: examine a política de segurança multicamadas
Abra o arquivo `lab_08_1.yaml` localizado na pasta `workshop-assets/dia-2`. Você notará que segmentamos a arquitetura em 4 rotas e 4 consumidores:

1. **`mock-public`**: Protegido por `key-auth`. O consumidor `partner-app` possui a chave estática `secret-123`.
2. **`mock-legacy`**: Protegido por `basic-auth`. O consumidor `legacy-app` possui nome de usuário `admin` e senha `password`.
3. **`mock-internal`**: Protegido por `jwt`. O consumidor `internal-app` possui a chave criptográfica para validar assinaturas JWT.
4. **`mock-b2b`**: Protegido por `hmac-auth`. O consumidor `b2b-app` compartilha um segredo (`banking-secret`) com Kong, que nunca viaja pela rede.

Para aplicar essas políticas Zero Trust ao seu ambiente, execute o seguinte comando:

```bash
deck gateway sync lab_08_1.yaml && \
echo "Esperando 15s para que Konnect actualice el Data Plane..." && sleep 15
```
## Etapa 2: Rejeição de teste (acesso negado padrão)
Tentaremos fazer solicitações anônimas para as 4 rotas. Você verá que Kong bloqueia tudo.

```bash
curl -s -D /dev/stderr http://localhost:8000/api/v1/public
curl -s -D /dev/stderr http://localhost:8000/api/v1/legacy
curl -s -D /dev/stderr http://localhost:8000/api/v1/internal
curl -s -D /dev/stderr http://localhost:8000/api/v1/b2b
```
**Para Windows (CMD):**

```cmd
curl -s -D /dev/stderr http://localhost:8000/api/v1/public
curl -s -D /dev/stderr http://localhost:8000/api/v1/legacy
curl -s -D /dev/stderr http://localhost:8000/api/v1/internal
curl -s -D /dev/stderr http://localhost:8000/api/v1/b2b
```
**Analisando o resultado:**
Todas as quatro respostas começarão com `HTTP/1.1 401 Unauthorized` mas as mensagens de erro serão específicas:

- *Público:* `{"message":"Nenhuma chave de API encontrada na solicitação"}`
- *Legado:* `{"message":"Não autorizado"}`
- *Interno:* `{"message":"Não autorizado"}`
- *B2B:* `{"message":"A assinatura HMAC não pode ser verificada, uma data válida ou um cabeçalho de data x é necessário para a autenticação HMAC"}`

Nenhuma chamada chegou ao seu back-end.

## Etapa 3: Acesso à rota pública (chave API)
Injete a credencial válida para a rota pública usando o cabeçalho que especificamos (`apikey`):

```bash
curl -s -D /dev/stderr -H "apikey: secreto-123" http://localhost:8000/api/v1/public 
```
**Para Windows (CMD):**

```cmd
curl -s -D /dev/stderr -H "apikey: secreto-123" http://localhost:8000/api/v1/public 
```
Você receberá um lindo `200 OK`.

## Etapa 4: Acesse o caminho legado (autenticação básica)
Injete credenciais de autenticação básica. Usaremos o sinalizador `-u` do curl, que converte automaticamente `user:password` em uma string Base64 no cabeçalho `Authorization`:

```bash
curl -s -D /dev/stderr -u admin:password http://localhost:8000/api/v1/legacy
```
**Para Windows (CMD):**

```cmd
curl -s -D /dev/stderr -u admin:password http://localhost:8000/api/v1/legacy
```
Você receberá um `200 OK`.

## Passo 5: Acesso à rota interna (JWT)
Para a rota interna, o microsserviço deve gerar um JSON Web Token assinado. Para facilitar o laboratório, aqui está um token pré-assinado válido para este ambiente (ele é assinado com o segredo `super-secret-jwt` declarado em seu arquivo yaml):

```bash
export TOKEN="eyJhbGciOiAiSFMyNTYiLCAidHlwIjogIkpXVCJ9.eyJpc3MiOiAiaW50ZXJuYWwtYXBwIn0g.kBkiqU62QjxhNZnPSQsgBt6gTfH4ZbFthSSpPs3mI6s"

curl -s -D /dev/stderr -H "Authorization: Bearer $TOKEN" http://localhost:8000/api/v1/internal
```
Você receberá um `200 OK`. Se você tentar alterar pelo menos uma letra do Token, a assinatura criptográfica será quebrada e Kong retornará um `401 Unauthorized`.

## Passo 6: Acesso à rota B2B (Autenticação HMAC)
HMAC (*código de autenticação de mensagem baseado em hash*) é o padrão ouro para integrações bancárias onde você **não confia na rede**. Ao contrário das chaves de API ou da autenticação básica, o segredo **nunca viaja na solicitação HTTP**.

O cliente (seu terminal) deve pegar o segredo e, junto com a data atual da transação, calcular matematicamente um Hash único (a assinatura) e enviar apenas essa assinatura para o Kong. Kong, que também conhece o segredo, faz o mesmo cálculo e verifica se coincidem.

Execute este script em seu console. Calcule a data dinamicamente e a assinatura HMAC usando `openssl` antes de injetá-la no `curl`:

```bash
DATE=$(date -u "+%a, %d %b %Y %H:%M:%S GMT")
SIGNATURE=$(echo -n "date: $DATE" | openssl dgst -sha256 -hmac "secreto-bancario" -binary | base64)

curl -s -D /dev/stderr -X GET http://localhost:8000/api/v1/b2b \
  -H "Date: $DATE" \
  -H 'Authorization: hmac username="banco-b", algorithm="hmac-sha256", headers="date", signature="'"$SIGNATURE"'"'
```
Se tudo correr bem, você receberá um `200 OK`. Você acabou de mostrar ao Gateway que possui o segredo sem tê-lo enviado pela rede!

---
## Conclusão
Você implementou uma arquitetura **Zero Trust Security** altamente sofisticada e multicamadas. 
Você liberou seus microsserviços da responsabilidade de gerenciar bancos de dados de usuários, descriptografar Basic Auth, validar assinaturas JWT ou recalcular hashes matemáticos HMAC para B2B. Kong centraliza todo o peso da criptografia e autenticação na borda da rede com latências de um dígito em milissegundos.
