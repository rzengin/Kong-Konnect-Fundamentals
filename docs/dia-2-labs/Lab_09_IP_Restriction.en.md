# Lab 09: IP Restriction

In this lab, we will protect an API at the network level (layer 3/4) using the `ip-restriction` plugin, ensuring that only specific addresses can consume back-office services.

```mermaid
flowchart LR
  classDef client fill:#f8fafc,stroke:#64748b,stroke-width:2px,color:#0f172a,rx:5,ry:5;
  classDef attacker fill:#fee2e2,stroke:#ef4444,stroke-width:2px,color:#7f1d1d,rx:5,ry:5;
  classDef kong fill:#d1fae5,stroke:#059669,stroke-width:2px,color:#064e3b,rx:10,ry:10;
  classDef backend fill:#f1f5f9,stroke:#475569,stroke-width:2px,color:#0f172a,rx:5,ry:5;
  classDef plugin fill:#ccfbf1,stroke:#0d9488,stroke-width:2px,color:#115e59;

  C(["Valid User"]):::client
  A(["Attacker"]):::attacker
  
  subgraph Gateway ["Kong Data Plane"]
    P{"Plugin<br/>(ip-restriction)"}:::plugin
  end
  Gateway:::kong

  B["Upstream<br/>(httpbin-backend)"]:::backend

  C -- "Request" --> P
  A -- "Request" --> P
  P -- "Allow" --> B
  P -. "Deny<br/>(Blacklisted IP)" .-> F(("403 Forbidden")):::attacker
```

## Objectives

- Configure an allowed IP whitelist.
- Use environment variable interpolation in decK files.

### Defense in Depth
Modern computer security does not rely on a single wall, but on multiple defensive layers. **IP restriction (OSI Model Layers 3 and 4)** is one of the most effective and computationally inexpensive first-line defenses.

Before Kong wastes CPU verifying cryptographic signatures of JWT tokens or evaluating complex routing rules, the **IP Restriction** plugin can immediately discard traffic if it comes from:
- Known malicious IP addresses (Blacklisting).
- Unauthorized geographies or CIDR ranges.
- Requests not originating from the corporate intranet (Whitelisting).

### IP Restriction Flow (Sequence Diagram)

```mermaid
sequenceDiagram
  participant Attacker as Attacker (IP: 192.168.1.100)
  participant User as Valid User (IP: 10.0.0.5)
  participant Kong as Kong Gateway (IP Restriction)
  participant Backend as Backend Service

  alt Blocked IP (Blacklist)
    Attacker->>Kong: GET /secure-api
    Note right of Kong: Evaluates origin against IP Restriction.<br/>IP matches denial.
    Kong-->>Attacker: 403 Forbidden (Access Denied)
    Note over Kong, Backend: Malicious traffic dies at the Edge
  else Allowed IP
    User->>Kong: GET /secure-api
    Note right of Kong: Evaluates origin. IP is not blocked.<br/>(Allows passage to subsequent plugins)
    Kong->>Backend: Routes request
    Backend-->>Kong: 200 OK
    Kong-->>User: 200 OK
  end
```

---

## Step 1: Configure the Restriction

Imagine we have an internal reports endpoint that should only be accessible from the corporate network.

Open the `lab_09_1.yaml` file located in the `workshop-assets/dia-2` folder and analyze its content:

```yaml
_format_version: "3.0"
services:
 - name: mock-internal-reports
  url: http://httpbin-backend:9081/anything/reports
  routes:
   - name: internal-reports-route
    paths: 
     - /api/internal/reports
    plugins:
     - name: ip-restriction
      config:
       allow:
        - 127.0.0.1
 # decK allows interpolating environment variables from your local machine
         - ${{ env "DECK_DOCKER_HOST_IP" }}
```

**Key Points:**

- **`ip-restriction` Plugin:** This network layer plugin blocks all traffic by default (explicit `allow` behavior). Only the listed IPs (in this case, localhost and the Docker environment host IP) will be able to reach the `mock-internal-reports` service.
- **Interpolation in decK:** Using `${{ env "VARIABLE" }}` avoids hardcoding static IPs or secrets in YAML files, promoting portability across environments (Dev, QA, Prod).

## Step 2: Apply and Test Blocking (External Attacker)
We will export the necessary environment variable, synchronize, and then simulate being a user from an external network using the `X-Real-Ip` header.

```bash
export DECK_DOCKER_HOST_IP="192.168.65.1" && \
deck gateway sync lab_09_1.yaml && \
echo "Waiting 15s for Konnect to update the Data Plane..." && sleep 15 && \
curl -s -D /dev/stderr -H "X-Real-Ip: 200.150.10.20" http://localhost:8000/api/internal/reports 
```

**Analyzing the result:**

- Observe the HTTP response: You will get a resounding `403 Forbidden`.
- Kong has intercepted the traffic, returning the JSON `{"message":"Your IP address is not allowed"}`.
- Even if the attacker knows the secret reports path, the Gateway's network layer stopped them in milliseconds.

## Step 3: Test Valid Access (Internal Network)
Now we will launch the request simulating traffic genuinely coming from our local machine (or the Docker host), which is explicitly whitelisted by Kong.

```bash
curl -s -D /dev/stderr http://localhost:8000/api/internal/reports 
```

**For Windows (CMD):**
```cmd
curl -s -D /dev/stderr http://localhost:8000/api/internal/reports 
```

**Analyzing the result:**

- The HTTP code will now be `200 OK`.
- The payload successfully passed through the L4 Firewall implemented by Kong, and the `httpbin` backend returned the requested information.

---
## Conclusion
We have established a strong defense perimeter at the Gateway level without having to manipulate Cloud Security Groups or internal operating system Firewalls of the nodes, configuring everything declaratively with decK.