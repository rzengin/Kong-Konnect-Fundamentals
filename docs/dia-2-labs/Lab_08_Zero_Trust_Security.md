# Laboratorio 08: Seguridad Zero Trust (Key, Basic Auth, JWT y HMAC)

El modelo de seguridad **Zero Trust** se basa en un principio fundamental: *"Nunca confíes, siempre verifica"*. No importa si una petición proviene de internet público, de un sistema legacy interno, o de un microservicio moderno dentro de la misma VPC; el API Gateway bloqueará todo el tráfico por defecto a menos que se presente una credencial criptográfica válida.

En este laboratorio vamos a proteger 4 servicios distintos simulando las arquitecturas más comunes en una empresa, forzando a los consumidores a autenticarse.

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

- Configurar los plugins `key-auth`, `basic-auth`, `jwt` y `hmac-auth` a nivel de servicio.
- Crear `Consumers` (Aplicaciones) declarativamente con sus respectivas credenciales.
- Validar que ninguna ruta permite tráfico anónimo.
- Comprender la diferencia entre enviar un secreto por la red y enviar una firma matemática (HMAC).

---

## Paso 1: Examinar la Política de Seguridad Multicapa
Abre el archivo `lab_08_1.yaml` ubicado en la carpeta `workshop-assets/dia-2`. Notarás que hemos segmentado la arquitectura en 4 rutas y 4 consumidores:

1. **`mock-public`**: Protegido por `key-auth`. El consumidor `partner-app` tiene la llave estática `secreto-123`.
2. **`mock-legacy`**: Protegido por `basic-auth`. El consumidor `legacy-app` tiene usuario `admin` y contraseña `password`.
3. **`mock-internal`**: Protegido por `jwt`. El consumidor `internal-app` tiene la clave criptográfica para validar las firmas JWT.
4. **`mock-b2b`**: Protegido por `hmac-auth`. El consumidor `b2b-app` comparte un secreto (`secreto-bancario`) con Kong, el cual nunca viaja por la red.

Para aplicar estas políticas Zero Trust a tu entorno, ejecuta el siguiente comando:

```bash
deck gateway sync lab_08_1.yaml && \
echo "Esperando 15s para que Konnect actualice el Data Plane..." && sleep 15
```

## Paso 2: Probar el Rechazo (Acceso Denegado por Defecto)
Vamos a intentar realizar peticiones anónimas a las 4 rutas. Verás que Kong bloquea todo.

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

**Analizando el resultado:**
Las cuatro respuestas comenzarán con `HTTP/1.1 401 Unauthorized` pero los mensajes de error serán específicos:

- *Public:* `{"message":"No API key found in request"}`
- *Legacy:* `{"message":"Unauthorized"}`
- *Internal:* `{"message":"Unauthorized"}`
- *B2B:* `{"message":"HMAC signature cannot be verified, a valid date or x-date header is required for HMAC Authentication"}`

Ninguna llamada llegó a tu backend.

## Paso 3: Acceso a la ruta Pública (API Key)
Inyecta la credencial válida para la ruta pública mediante el header que especificamos (`apikey`):

```bash
curl -s -D /dev/stderr -H "apikey: secreto-123" http://localhost:8000/api/v1/public 
```

**Para Windows (CMD):**
```cmd
curl -s -D /dev/stderr -H "apikey: secreto-123" http://localhost:8000/api/v1/public 
```
Recibirás un hermoso `200 OK`.

## Paso 4: Acceso a la ruta Legacy (Basic Auth)
Inyecta las credenciales de Basic Auth. Usaremos la bandera `-u` de curl, que automáticamente convierte el `usuario:password` en un string Base64 en el header `Authorization`:

```bash
curl -s -D /dev/stderr -u admin:password http://localhost:8000/api/v1/legacy
```

**Para Windows (CMD):**
```cmd
curl -s -D /dev/stderr -u admin:password http://localhost:8000/api/v1/legacy
```
Recibirás un `200 OK`.

## Paso 5: Acceso a la ruta Interna (JWT)
Para la ruta interna, el microservicio debe generar un JSON Web Token firmado. Para facilitar el laboratorio, aquí tienes un token pre-firmado válido para este entorno (está firmado con el secreto `super-secret-jwt` declarado en tu archivo yaml):

```bash
export TOKEN="eyJhbGciOiAiSFMyNTYiLCAidHlwIjogIkpXVCJ9.eyJpc3MiOiAiaW50ZXJuYWwtYXBwIn0g.kBkiqU62QjxhNZnPSQsgBt6gTfH4ZbFthSSpPs3mI6s"

curl -s -D /dev/stderr -H "Authorization: Bearer $TOKEN" http://localhost:8000/api/v1/internal
```
Recibirás un `200 OK`. Si intentas alterar siquiera una letra del Token, la firma criptográfica se romperá y Kong te devolverá un `401 Unauthorized`.

## Paso 6: Acceso a la ruta B2B (HMAC Authentication)
HMAC (*Hash-based Message Authentication Code*) es el estándar de oro para integraciones bancarias donde **no confías en la red**. A diferencia de API Keys o Basic Auth, el secreto **jamás viaja en la petición HTTP**.

El cliente (tu terminal) debe tomar el secreto y, junto con la fecha actual de la transacción, calcular matemáticamente un Hash único (la firma) y enviar únicamente esa firma a Kong. Kong, que también conoce el secreto, hace el mismo cálculo y verifica si coinciden.

Ejecuta este script en tu consola. Calcula la fecha dinámicamente y la firma HMAC usando `openssl` antes de inyectarla en el `curl`:

```bash
DATE=$(date -u "+%a, %d %b %Y %H:%M:%S GMT")
SIGNATURE=$(echo -n "date: $DATE" | openssl dgst -sha256 -hmac "secreto-bancario" -binary | base64)

curl -s -D /dev/stderr -X GET http://localhost:8000/api/v1/b2b \
  -H "Date: $DATE" \
  -H 'Authorization: hmac username="banco-b", algorithm="hmac-sha256", headers="date", signature="'"$SIGNATURE"'"'
```

Si todo sale bien, recibirás un `200 OK`. ¡Acabas de demostrar al Gateway que posees el secreto sin haberlo enviado por la red!

---
## Conclusión
Has implementado una arquitectura de **Seguridad Zero Trust** multicapa y altamente sofisticada. 
Descargaste a tus microservicios de la responsabilidad de gestionar bases de datos de usuarios, desencriptar Basic Auth, validar firmas JWT, o recalcular hashes HMAC matemáticos para B2B. Kong centraliza todo el peso de la criptografía y la autenticación en el perímetro de la red con latencias de un solo dígito de milisegundos.
