# Integração ITSM (Alertas e Ticketing)

## Objetivo
Demonstrar como o Kong pode disparar a criação automática de incidentes em ferramentas de ITSM (ServiceNow/Jira) de forma padrão e independente do Datadog.

## Conteúdo Teórico
Em arquiteturas distribuídas e orientadas a microsserviços, a observabilidade e a resposta a incidentes são críticas. O Kong Gateway fica na borda da rede, o que lhe permite ter visibilidade completa do tráfego que flui para as APIs. Aproveitando esta posição privilegiada, o Kong pode detectar anomalias, como um aumento incomum na taxa de erros (por exemplo, códigos de status HTTP 5xx), e notificar imediatamente os sistemas de Gerenciamento de Serviços de TI (ITSM) corporativos, como ServiceNow ou Jira Service Management.

### Arquitetura do Fluxo
1. **Detecção no Kong:** O Kong processa o tráfego e, por meio de plugins (como `http-log` ou `pre-function`), avalia o status das respostas.
2. **Disparo do Alerta:** Ao detectar uma condição de erro (ex. um HTTP 500), o plugin configurado faz uma chamada assíncrona.
3. **Envio de Webhook:** Um Webhook genérico com formato JSON é enviado para o endpoint do sistema ITSM.
4. **Criação do Ticket:** O sistema ITSM recebe o payload JSON, o analisa e gera automaticamente um ticket de incidente, atribuindo-o à equipe apropriada para resolução imediata.

## Laboratório Prático

Neste laboratório, configuraremos o plugin `http-log` para que envie um payload JSON simulando a criação de um ticket em um sistema ITSM diante de um erro 5xx.

### Passo 1: Configurar o plugin `http-log`
Vamos adicionar o plugin à nossa rota ou serviço para enviar logs a um endpoint simulado (exemplo: um webhook de [webhook.site](https://webhook.site)).

```yaml
plugins:
  - name: http-log
    config:
      http_endpoint: "https://webhook.site/seu-id-de-webhook-aqui"
      method: "POST"
      timeout: 10000
      keepalive: 60000
      flush_timeout: 2
      retry_count: 10
      custom_fields_by_lua:
        ticket_info: |
          return {
            title = "Alerta API: " .. kong.request.get_path(),
            description = "Foi detectado um erro " .. kong.response.get_status() .. " no serviço.",
            priority = "High"
          }
```
*Nota: Em um ambiente real, você pode usar um plugin `serverless` (como `pre-function`) para ter um controle mais granular, executando código Lua que apenas envie o webhook se o código de status for `> 499` e estruturando o payload exatamente como exigido pela API do ServiceNow ou Jira.*

### Passo 2: Testar o Fluxo
1. Gere um erro forçado em sua API. Para este laboratório, assumindo que você tenha uma rota apontando para um serviço de teste como `httpbin.org`, podemos forçar um erro HTTP 500 chamando o endpoint `/status/500`. Execute este comando no seu terminal:

   ```bash
   curl -i http://localhost:8000/mock/status/500
   ```
   *(Certifique-se de substituir `/mock` pela rota real que você configurou no Kong).*

2. Observe como o Kong recebe o HTTP 500 do backend, captura o evento e executa o plugin automaticamente.
3. Verifique no console do Webhook receptor (ex: webhook.site) se uma solicitação POST foi recebida. Dentro do corpo da solicitação (payload JSON), você poderá ver os dados do incidente prontos para serem consumidos pelo ITSM, semelhantes a este:

   ```json
   {
     "latencies": { "proxy": 140, "kong": 12, "request": 152 },
     "request": { "uri": "/mock/status/500", "method": "GET" },
     "response": { "status": 500 },
     "ticket_info": {
       "title": "Alerta API: /mock/status/500",
       "description": "Foi detectado um erro 500 no serviço.",
       "priority": "High"
     }
   }
   ```
