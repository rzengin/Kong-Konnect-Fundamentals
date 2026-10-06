# Segurança OWASP (WAF)

## Objetivo
Proteger as APIs contra ameaças críticas identificadas no OWASP Top 10 (especialmente Injeções e BOLA).

## Conteúdo Teórico
Como as APIs se tornaram o motor da economia digital e o principal vetor de ataque, a proteção de rede tradicional (firewalls da camada 4) não é mais suficiente. O **OWASP API Security Top 10** destaca as vulnerabilidades modernas mais severas, incluindo ataques de Injeção (SQL, NoSQL, Comandos) e vulnerabilidades de autorização como BOLA (Broken Object Level Authorization).

A implementação de um **Web Application Firewall (WAF)** diretamente no API Gateway representa uma estratégia robusta de defesa em profundidade. O WAF é responsável por analisar na camada 7 (HTTP/HTTPS) todo o tráfego de entrada — incluindo headers, query parameters e o corpo da solicitação — em busca de assinaturas e comportamentos maliciosos antes mesmo de chegarem aos microsserviços de backend.

No Kong, essa proteção de classe empresarial é alcançada integrando plugins WAF (como **Coraza WAF** ou ModSecurity). Esses mecanismos de avaliação usam regras padrão do setor, como o *OWASP Core Rule Set (CRS)*, para identificar e mitigar proativamente ameaças complexas. Ao centralizar essa inteligência no Gateway, as organizações garantem políticas de segurança consistentes, conformidade regulatória (PCI-DSS, HIPAA) e blindagem eficaz para todo o seu catálogo de APIs.

## Laboratório Prático

Nesta demonstração, configuraremos um WAF no Kong para bloquear uma tentativa de ataque de Injeção SQL.

### Passo 1: Habilitar o Plugin WAF
Aplicaremos a configuração declarativa (YAML) para habilitar o plugin WAF em nossa API. Neste exemplo, configuraremos o plugin para habilitar o mecanismo de regras e incluir a proteção SQLi específica do OWASP CRS.

```yaml
plugins:
  - name: coraza # (ou 'modsecurity' dependendo da versão/ambiente)
    config:
      directives: |
        SecRuleEngine On
        SecRequestBodyAccess On
        Include @owasp_crs/REQUEST-942-APPLICATION-ATTACK-SQLI.conf
```
*(Nota: Em ambientes corporativos do Kong, as regras OWASP CRS geralmente vêm pré-configuradas ou empacotadas).*

### Passo 2: Caso de Teste Normal (Tráfego Legítimo)
Verificamos se o tráfego válido flui sem interrupção enviando uma solicitação padrão:
```bash
curl -i http://localhost:8000/api/users?id=123
```
*Resultado esperado:* A solicitação passa pelas verificações do WAF, chega ao backend e retorna um HTTP 200 OK.

### Passo 3: Caso de Teste Malicioso (SQL Injection)
Simulamos um invasor tentando contornar a autenticação ou extrair dados usando injeção clássica de SQL por meio dos parâmetros de URL.

Enviamos o payload malicioso:
```bash
curl -i "http://localhost:8000/api/users?id=1'%20OR%20'1'='1"
```
*(Isso se traduz na URL: `?id=1' OR '1'='1`)*

*Resultado esperado:*
O Kong processa a solicitação e o plugin WAF inspeciona os parâmetros. Ele detecta imediatamente a assinatura característica da injeção de SQL (avaliação lógica anômala) e bloqueia o acesso no próprio Gateway, sem comprometer o backend.

O invasor receberá um código de status HTTP 403:

```http
HTTP/1.1 403 Forbidden
Content-Type: application/json
Connection: keep-alive

{
    "message": "Forbidden. Web Application Firewall (WAF) blocked the request."
}
```
