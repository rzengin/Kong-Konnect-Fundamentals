# Lab IA 07: A2A — um agente delega a outro através do gateway

Neste laboratório você vai publicar o **agente antifraude** (protocolo A2A, simulado com WireMock) atrás do AI Gateway. O copiloto de operações poderá descobri-lo e delegar a ele a avaliação de uma transferência; o agente de consultas não.

```mermaid
sequenceDiagram
    participant CP as agente-copilot
    participant GW as AI Gateway /agentes/antifraude
    participant AF as Agente antifraude (WireMock)
    participant CQ as agente-consulta

    CP->>GW: GET /.well-known/agent-card.json (apikey)
    GW->>AF: proxy
    AF-->>GW: Agent Card (skills: evaluar-riesgo)
    GW-->>CP: Agent Card
    CP->>GW: POST / JSON-RPC message/send (tx-9001)
    GW->>AF: proxy + logging + analytics A2A
    AF-->>GW: score 94, BLOQUEAR
    GW-->>CP: 200
    CQ->>GW: POST / message/send
    GW-->>CQ: 403 (ACL: somente agentes-operaciones)
```

## Objetivos

- Declarar uma entidade `ai_gateway_agents` (`type: a2a`).
- Descobrir um agente pelo seu **Agent Card** através do gateway.
- Invocá-lo com JSON-RPC (`message/send`).
- Verificar autenticação e ACL entre agentes.
- Exercício: publicar um segundo agente (scoring de crédito).

---

## Passo 1: Revisar a configuração e aplicar

`workshop-assets/dia-4/config/lab_07_a2a.yaml`:

```yaml
ai_gateway_agents:
  - ref: agente-antifraude
    ai_gateway: !ref lab-ai-gw#id
    type: a2a
    name: agente-antifraude
    display_name: Agente antifraude (A2A)
    access:
      auth_strategies: [!ref lab-key-auth#name]
      acls:
        allow: [agentes-operaciones]
    config:
      url: http://wiremock:8080/antifraude/
      route:
        paths: [/agentes/antifraude]
      logging: {payloads: true, statistics: true}
```

```bash
./workshop-assets/dia-4/scripts/aplicar.sh 07
source ~/.kong-workshop/aigw-lab/.env.generated
A2A=http://localhost:8010/agentes/antifraude
SEND='{"jsonrpc":"2.0","id":"1","method":"message/send","params":{"message":{"role":"user","messageId":"m-1","parts":[{"kind":"text","text":"Evaluar transferencia tx-9001: USD 5.500 a cuenta creada hace 2 h, 23:41 h."}]}}}'
```

## Passo 2: Descoberta (Agent Card)

```bash
curl -s -H "apikey: $AIGW_KEY_AGENTE_COPILOT" "$A2A/.well-known/agent-card.json" | jq '{name, url, skills: [.skills[].id]}'
```

**Resultado esperado:** `"name": "Agente Antifraude"` com a skill `evaluar-riesgo`.

## Passo 3: Delegação

```bash
curl -s -X POST "$A2A/" -H "apikey: $AIGW_KEY_AGENTE_COPILOT" -H "Content-Type: application/json" -d "$SEND" \
  | jq '.result.parts[0].data'
```

**Resultado esperado:**

```json
{
  "score_riesgo": 94,
  "recomendacion": "BLOQUEAR",
  "motivo": "Transferencia de alto monto a cuenta creada hace menos de 24 h, fuera del horario habitual del cliente."
}
```

## Passo 4: Governança do tráfego entre agentes

```bash
curl -s -o /dev/null -w "sin credencial:   %{http_code}\n" -X POST "$A2A/" -H "Content-Type: application/json" -d "$SEND"
curl -s -o /dev/null -w "agente-consulta:  %{http_code}\n" -X POST "$A2A/" -H "apikey: $AIGW_KEY_AGENTE_CONSULTA" -H "Content-Type: application/json" -d "$SEND"
curl -s -o /dev/null -w "agente-copilot:   %{http_code}\n" -X POST "$A2A/" -H "apikey: $AIGW_KEY_AGENTE_COPILOT" -H "Content-Type: application/json" -d "$SEND"
```

**Resultado esperado:** `401`, `403`, `200`.

No Konnect → **Analytics**: as interações A2A aparecem com o seu consumer e estatísticas.

## Passo 5: Juntar MCP + A2A (fluxo do copiloto)

Simule o fluxo completo de um copiloto de operações (os labs 06 e 07 precisam estar aplicados):

```bash
mcp() { python3 workshop-assets/dia-4/scripts/mcp_client.py "$@"; }
# 1) LER (MCP): últimas transações
mcp http://localhost:8010/mcp/banco "$AIGW_KEY_AGENTE_COPILOT" call listar_transacciones '{"cuenta_id":"1001"}' | jq -r '.result.content[0].text' | head -8
# 2) DELEGAR (A2A): avaliação de risco
REC=$(curl -s -X POST "$A2A/" -H "apikey: $AIGW_KEY_AGENTE_COPILOT" -H "Content-Type: application/json" -d "$SEND" | jq -r '.result.parts[0].data.recomendacion')
echo "Recomendación antifraude: $REC"
# 3) AGIR (MCP): bloquear somente se for o caso
[ "$REC" = "BLOQUEAR" ] && mcp http://localhost:8010/mcp/banco "$AIGW_KEY_AGENTE_COPILOT" call bloquear_cuenta '{"cuenta_id":"1001"}' | jq -r '.result.content[0].text'
```

Os três passos passaram pelo gateway com a mesma identidade (`agente-copilot`) e ficaram auditados.

## Passo 6: Exercício

O WireMock também simula um **agente de scoring de crédito** em `http://wiremock:8080/scoring/`:

```bash
curl -s http://localhost:8089/scoring/.well-known/agent-card.json | jq '{name, skills: [.skills[].id]}'
```

Publique-o no gateway em **`/agentes/scoring`**, acessível **apenas** para o grupo **`plan-premium`**. Aplique e verifique:

```bash
S=http://localhost:8010/agentes/scoring
SEND2='{"jsonrpc":"2.0","id":"2","method":"message/send","params":{"message":{"role":"user","messageId":"m-2","parts":[{"kind":"text","text":"Solicitud de préstamo personal USD 8.000 a 24 meses, ingreso neto USD 2.400."}]}}}'
curl -s -X POST "$S/" -H "apikey: $AIGW_KEY_EQUIPO_DATOS" -H "Content-Type: application/json" -d "$SEND2" | jq '.result.parts[0].data'   # 200
curl -s -o /dev/null -w "%{http_code}\n" -X POST "$S/" -H "apikey: $AIGW_KEY_APP_WEB" -H "Content-Type: application/json" -d "$SEND2"   # 403
```

??? tip "Solução"
    `workshop-assets/dia-4/soluciones/lab_07_a2a.yaml`:
    ```yaml
    - ref: agente-scoring
      ai_gateway: !ref lab-ai-gw#id
      type: a2a
      name: agente-scoring
      display_name: Agente de scoring crediticio (A2A)
      access:
        auth_strategies: [!ref lab-key-auth#name]
        acls:
          allow: [plan-premium]
      config:
        url: http://wiremock:8080/scoring/
        route:
          paths: [/agentes/scoring]
        logging: {payloads: true, statistics: true}
    ```
    `./workshop-assets/dia-4/scripts/aplicar.sh 07 --solucion`

---

## Conclusão

LLMs, tools MCP e agentes A2A compartilham o mesmo plano de controle: identidade, ACL e auditoria. Nenhum agente pode delegar a outro sem autorização explícita. Teoria: [Módulo IA 07](../dia-3-ai-gateway-teoria-y-demos/07-agentes-a2a/Guia_IA_07_Agentes_y_A2A.md). Próximo: [Lab IA 08 — Observabilidade de IA](Lab_IA_08_Observabilidad.md).
