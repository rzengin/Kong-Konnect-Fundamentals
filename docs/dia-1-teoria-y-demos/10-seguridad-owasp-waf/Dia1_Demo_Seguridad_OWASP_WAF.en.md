# OWASP Security (WAF)

## Objective
Protect APIs against critical threats identified in the OWASP Top 10 (especially Injections and BOLA).

## Theoretical Content
As APIs have become the engine of the digital economy and the primary attack vector, traditional network protection (layer 4 firewalls) is no longer sufficient. The **OWASP API Security Top 10** highlights the most severe modern vulnerabilities, including Injection attacks (SQL, NoSQL, Commands) and authorization vulnerabilities like BOLA (Broken Object Level Authorization).

Implementing a **Web Application Firewall (WAF)** directly on the API Gateway represents a robust defense-in-depth strategy. The WAF is responsible for analyzing all incoming traffic at layer 7 (HTTP/HTTPS) —including headers, query parameters, and the request body— in search of malicious signatures and behaviors before they even reach the backend microservices.

In Kong, this enterprise-grade protection is achieved through the integration of WAF plugins (such as **Coraza WAF** or ModSecurity). These evaluation engines use industry-standard rules, such as the *OWASP Core Rule Set (CRS)*, to proactively identify and mitigate complex threats. By centralizing this intelligence at the Gateway, organizations ensure consistent security policies, regulatory compliance (PCI-DSS, HIPAA), and effective shielding for their entire API catalog.

## Practical Lab

In this demonstration, we will configure a WAF in Kong to block an attempted SQL Injection attack.

### Step 1: Enable the WAF Plugin
We will apply the declarative configuration (YAML) to enable the WAF plugin on our API. In this example, we will configure the plugin to enable the rule engine and include specific SQLi protection from OWASP CRS.

```yaml
plugins:
  - name: coraza # (or 'modsecurity' depending on the version/environment)
    config:
      directives: |
        SecRuleEngine On
        SecRequestBodyAccess On
        Include @owasp_crs/REQUEST-942-APPLICATION-ATTACK-SQLI.conf
```
*(Note: In enterprise Kong environments, OWASP CRS rules usually come pre-configured or packaged).*

### Step 2: Normal Test Case (Legitimate Traffic)
We verify that valid traffic flows without interruptions by sending a standard request:
```bash
curl -i http://localhost:8000/api/users?id=123
```
*Expected Result:* The request passes the WAF controls, reaches the backend, and returns an HTTP 200 OK.

### Step 3: Malicious Test Case (SQL Injection)
We simulate an attacker attempting to bypass authentication or extract data using a classic SQL injection through URL parameters.

We send the malicious payload:
```bash
curl -i "http://localhost:8000/api/users?id=1'%20OR%20'1'='1"
```
*(This translates to the URL: `?id=1' OR '1'='1`)*

*Expected Result:*
Kong processes the request and the WAF plugin inspects the parameters. It immediately detects the characteristic SQL injection signature (anomalous logical evaluation) and blocks access at the Gateway itself, without compromising the backend.

The attacker will receive an HTTP 403 status code:

```http
HTTP/1.1 403 Forbidden
Content-Type: application/json
Connection: keep-alive

{
    "message": "Forbidden. Web Application Firewall (WAF) blocked the request."
}
```