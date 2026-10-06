# Seguridad OWASP (WAF)

## Objetivo
Proteger las APIs contra las amenazas críticas identificadas en el OWASP Top 10 (especialmente Inyecciones y BOLA).

## Contenido Teórico
A medida que las APIs se han convertido en el motor de la economía digital y el principal vector de ataque, la protección de red tradicional (firewalls de capa 4) ya no es suficiente. El **OWASP API Security Top 10** destaca las vulnerabilidades modernas más severas, incluyendo ataques de Inyección (SQL, NoSQL, Comandos) y vulnerabilidades de autorización como BOLA (Broken Object Level Authorization).

Implementar un **Web Application Firewall (WAF)** directamente en el API Gateway representa una estrategia robusta de defensa en profundidad. El WAF se encarga de analizar a nivel de capa 7 (HTTP/HTTPS) todo el tráfico entrante —incluyendo headers, query parameters y el cuerpo de la petición— en busca de firmas y comportamientos maliciosos antes de que siquiera alcancen los microservicios de backend.

En Kong, esta protección de clase empresarial se logra mediante la integración de plugins de WAF (como **Coraza WAF** o ModSecurity). Estos motores de evaluación utilizan reglas estándar de la industria, como el *OWASP Core Rule Set (CRS)*, para identificar y mitigar de forma proactiva amenazas complejas. Al centralizar esta inteligencia en el Gateway, las organizaciones garantizan políticas de seguridad consistentes, cumplimiento normativo (PCI-DSS, HIPAA) y un blindaje efectivo para todo su catálogo de APIs.

## Laboratorio Práctico

En esta demostración, configuraremos un WAF en Kong para bloquear un intento de ataque de Inyección SQL.

### Paso 1: Habilitar el Plugin WAF
Aplicaremos la configuración declarativa (YAML) para habilitar el plugin WAF en nuestra API. En este ejemplo, configuraremos el plugin para habilitar el motor de reglas e incluir la protección específica contra SQLi de OWASP CRS.

```yaml
plugins:
  - name: coraza # (o 'modsecurity' dependiendo de la versión/entorno)
    config:
      directives: |
        SecRuleEngine On
        SecRequestBodyAccess On
        Include @owasp_crs/REQUEST-942-APPLICATION-ATTACK-SQLI.conf
```
*(Nota: En entornos empresariales de Kong, las reglas CRS de OWASP suelen venir preconfiguradas o empaquetadas).*

### Paso 2: Caso de Prueba Normal (Tráfico Legítimo)
Comprobamos que el tráfico válido fluye sin interrupciones enviando una petición estándar:
```bash
curl -i http://localhost:8000/api/users?id=123
```
*Resultado esperado:* La petición supera los controles del WAF, llega al backend y retorna un HTTP 200 OK.

### Paso 3: Caso de Prueba Malicioso (SQL Injection)
Simulamos un atacante intentando eludir la autenticación o extraer datos mediante una inyección SQL clásica a través de los parámetros de la URL.

Enviamos el payload malicioso:
```bash
curl -i "http://localhost:8000/api/users?id=1'%20OR%20'1'='1"
```
*(Esto se traduce a la URL: `?id=1' OR '1'='1`)*

*Resultado esperado:*
Kong procesa la petición y el plugin WAF inspecciona los parámetros. Inmediatamente detecta la firma característica de inyección SQL (evaluación lógica anómala) y bloquea el acceso en el propio Gateway, sin comprometer el backend.

El atacante recibirá un código de estado HTTP 403:

```http
HTTP/1.1 403 Forbidden
Content-Type: application/json
Connection: keep-alive

{
    "message": "Forbidden. Web Application Firewall (WAF) blocked the request."
}
```
