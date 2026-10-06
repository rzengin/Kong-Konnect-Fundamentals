# Lab 08: Zero Trust Security (Key, Basic Auth, JWT, and HMAC)

The **Zero Trust** security model is based on a fundamental principle: *"Never trust, always verify"*. It doesn't matter if a request comes from the public internet, an internal legacy system, or a modern microservice within the same VPC; the API Gateway will block all traffic by default unless a valid cryptographic credential is presented.

In this lab, we will protect 4 different services, simulating the most common architectures in an enterprise, forcing consumers to authenticate.

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

## Objectives

- Configure the `key-auth`, `basic-auth`, `jwt`, and `hmac-auth` plugins at the service level.
- Create `Consumers` (Applications) declaratively with their respective credentials.
- Validate that no route allows anonymous traffic.
- Understand the difference between sending a secret over the network and sending a mathematical signature (HMAC).

---

## Step 1: Examine the Multi-Layer Security Policy
Open the `lab_08_1.yaml` file located in the `workshop-assets/dia-2` folder. You will notice that we have segmented the architecture into 4 routes and 4 consumers:

1.  **`mock-public`**: Protected by `key-auth`. The `partner-app` consumer has the static key `secreto-123`.
2.  **`mock-legacy`**: Protected by `basic-auth`. The `legacy-app` consumer has username `admin` and password `password`.
3.  **`mock-internal`**: Protected by `jwt`. The `internal-app` consumer has the cryptographic key to validate JWT signatures.
4.  **`mock-b2b`**: Protected by `hmac-auth`. The `b2b-app` consumer shares a secret (`secreto-bancario`) with Kong, which never travels over the network.

To apply these Zero Trust policies to your environment, run the following command:

```bash
deck gateway sync lab_08_1.yaml && \
echo "Waiting 15s for Konnect to update the Data Plane..." && sleep 15
```

## Step 2: Test Rejection (Access Denied by Default)
Let's try to make anonymous requests to all 4 routes. You will see that Kong blocks everything.

```bash
curl -s -D /dev/stderr http://localhost:8000/api/v1/public
curl -s -D /dev/stderr http://localhost:8000/api/v1/legacy
curl -s -D /dev/stderr http://localhost:8000/api/v1/internal
curl -s -D /dev/stderr http://localhost:8000/api/v1/b2b
```

**For Windows (CMD):**
```cmd
curl -s -D /dev/stderr http://localhost:8000/api/v1/public
curl -s -D /dev/stderr http://localhost:8000/api/v1/legacy
curl -s -D /dev/stderr http://localhost:8000/api/v1/internal
curl -s -D /dev/stderr http://localhost:8000/api/v1/b2b
```

**Analyzing the result:**
All four responses will start with `HTTP/1.1 401 Unauthorized` but the error messages will be specific:

-   *Public:* `{"message":"No API key found in request"}`
-   *Legacy:* `{"message":"Unauthorized"}`
-   *Internal:* `{"message":"Unauthorized"}`
-   *B2B:* `{"message":"HMAC signature cannot be verified, a valid date or x-date header is required for HMAC Authentication"}`

No calls reached your backend.

## Step 3: Access the Public Route (API Key)
Inject the valid credential for the public route using the header we specified (`apikey`):

```bash
curl -s -D /dev/stderr -H "apikey: secreto-123" http://localhost:8000/api/v1/public 
```

**For Windows (CMD):**
```cmd
curl -s -D /dev/stderr -H "apikey: secreto-123" http://localhost:8000/api/v1/public 
```
You will receive a beautiful `200 OK`.

## Step 4: Access the Legacy Route (Basic Auth)
Inject the Basic Auth credentials. We will use curl's `-u` flag, which automatically converts `username:password` into a Base64 string in the `Authorization` header:

```bash
curl -s -D /dev/stderr -u admin:password http://localhost:8000/api/v1/legacy
```

**For Windows (CMD):**
```cmd
curl -s -D /dev/stderr -u admin:password http://localhost:8000/api/v1/legacy
```
You will receive a `200 OK`.

## Step 5: Access the Internal Route (JWT)
For the internal route, the microservice must generate a signed JSON Web Token. To simplify the lab, here is a pre-signed token valid for this environment (it is signed with the `super-secret-jwt` secret declared in your yaml file):

```bash
export TOKEN="eyJhbGciOiAiSFMyNTYiLCAidHlwIjogIkpXVCJ9.eyJpc3MiOiAiaW50ZXJuYWwtYXBwIn0g.kBkiqU62QjxhNZnPSQsgBt6gTfH4ZbFthSSpPs3mI6s"

curl -s -D /dev/stderr -H "Authorization: Bearer $TOKEN" http://localhost:8000/api/v1/internal
```
You will receive a `200 OK`. If you try to alter even one letter of the Token, the cryptographic signature will break, and Kong will return a `401 Unauthorized`.

## Step 6: Access the B2B Route (HMAC Authentication)
HMAC (*Hash-based Message Authentication Code*) is the gold standard for banking integrations where you **do not trust the network**. Unlike API Keys or Basic Auth, the secret **never travels in the HTTP request**.

The client (your terminal) must take the secret and, along with the current transaction date, mathematically calculate a unique Hash (the signature) and send only that signature to Kong. Kong, which also knows the secret, performs the same calculation and verifies if they match.

Run this script in your console. It dynamically calculates the date and the HMAC signature using `openssl` before injecting it into the `curl`:

```bash
DATE=$(date -u "+%a, %d %b %Y %H:%M:%S GMT")
SIGNATURE=$(echo -n "date: $DATE" | openssl dgst -sha256 -hmac "secreto-bancario" -binary | base64)

curl -s -D /dev/stderr -X GET http://localhost:8000/api/v1/b2b \
  -H "Date: $DATE" \
  -H 'Authorization: hmac username="banco-b", algorithm="hmac-sha256", headers="date", signature="'"$SIGNATURE"'"'
```

If all goes well, you will receive a `200 OK`. You have just demonstrated to the Gateway that you possess the secret without having sent it over the network!

---
## Conclusion
You have implemented a multi-layered and highly sophisticated **Zero Trust Security** architecture.
You have offloaded your microservices from the responsibility of managing user databases, decrypting Basic Auth, validating JWT signatures, or recalculating mathematical HMAC hashes for B2B. Kong centralizes all the cryptographic and authentication burden at the network edge with single-digit millisecond latencies.