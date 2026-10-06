# Gerenciamento de Segredos (Kong Vaults)

## Objetivo
Mostrar como proteger informações confidenciais por meio do Gerenciamento Centralizado de Segredos usando Kong Vaults.

## Conteúdo Teórico
O gerenciamento de informações confidenciais, como chaves de API, senhas de banco de dados, certificados e tokens, é um pilar fundamental na segurança de qualquer infraestrutura moderna. Configurar essas credenciais em texto simples dentro de arquivos declarativos (YAML/JSON) ou bancos de dados expõe a organização a graves riscos de segurança.

O Kong Gateway resolve esse problema de forma elegante através de sua funcionalidade **Vaults**. Os Vaults permitem armazenar, gerenciar e acessar segredos de forma segura. Em vez de escrever o segredo real na configuração de um plugin, usa-se uma referência ao Vault (como um ponteiro). Em tempo de execução, o Kong resolve dinamicamente essa referência e obtém o valor real do segredo na memória, sem gravá-lo em logs ou expô-lo através da API de administração.

> [!INFO]
> **Extensibilidade e Padrão Corporativo**
> 
> Neste exercício usaremos o Vault interno nativo do Kong (`env`) para manter as coisas simples. No entanto, é vital notar que **este mesmo padrão de referência é usado de forma totalmente transparente para integração com Vaults externos corporativos**.
> 
> O Kong suporta nativamente integração com:
> - **AWS Secrets Manager** (`{vault://aws/...}`)
> - **GCP Secret Manager** (`{vault://gcp/...}`)
> - **HashiCorp Vault** (`{vault://hcv/...}`)
> 
> A sintaxe de referência segue o mesmo princípio. Isso permite que você migre de um ambiente local (usando variáveis de ambiente) para um ambiente de produção (conectado ao HashiCorp ou AWS) sem precisar alterar uma única linha da configuração declarativa das APIs.

## Laboratório Prático

Neste exercício, protegeremos uma API Key que precisamos enviar ao nosso backend (upstream), usando o Vault nativo baseado em variáveis de ambiente.

### Passo 1: Configurar o Segredo no Ambiente
Para o Vault nativo de variáveis de ambiente (`env`), devemos exportar a variável no sistema operacional ou contêiner antes de iniciar o Kong. O prefixo padrão que o Kong inspeciona é `KONG_VAULT_ENV_`.

```bash
export KONG_VAULT_ENV_BACKEND_API_KEY="super-secret-key-12345"
```
*(Reinicie o Kong se você estiver aplicando isso a uma instância em execução).*

### Passo 2: Referenciar o Segredo em um Plugin
Suponha que queremos usar o plugin `request-transformer` para injetar essa API Key nos cabeçalhos da solicitação antes de chegar ao nosso backend, mas não queremos que a chave fique visível em nossa configuração YAML.

Configuramos o plugin usando a sintaxe de referência do Vault:

```yaml
plugins:
  - name: request-transformer
    config:
      add:
        headers:
          - "x-api-key:{vault://env/backend_api_key}"
```

### Passo 3: Validação do Fluxo
1. Faça uma solicitação GET normal para sua API por meio do Gateway.
2. O Kong processará a solicitação, invocará o plugin, resolverá dinamicamente a referência `{vault://env/backend_api_key}` e substituirá a string pelo valor real `super-secret-key-12345` que está seguro na memória.
3. Verifique (usando um serviço como httpbin ou verificando os logs do upstream) se o backend recebe a solicitação com o cabeçalho injetado com sucesso: `x-api-key: super-secret-key-12345`.
