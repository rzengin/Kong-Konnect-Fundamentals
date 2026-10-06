# Secret Management (Kong Vaults)

## Objective
Demonstrate how to protect sensitive information using Centralized Secret Management with Kong Vaults.

## Theoretical Content
Managing confidential information, such as API keys, database passwords, certificates, and tokens, is a fundamental pillar in the security of any modern infrastructure. Configuring these credentials in plain text within declarative files (YAML/JSON) or databases exposes the organization to serious security risks.

Kong Gateway elegantly solves this problem through its **Vaults** functionality. Vaults allow for the secure storage, management, and access of secrets. Instead of writing the actual secret in a plugin's configuration, a reference to the Vault (like a pointer) is used. At runtime, Kong dynamically resolves this reference and retrieves the actual secret value in memory, without writing it to logs or exposing it through the administration API.

> [!INFO]
> **Extensibility and Enterprise Standard**
> 
> In this exercise, we will use Kong's native internal Vault (`env`) to keep it simple. However, it is vital to highlight that **this same standard of references is used completely transparently to integrate with external corporate Vaults**.
> 
> Kong natively supports integration with:
> - **AWS Secrets Manager** (`{vault://aws/...}`)
> - **GCP Secret Manager** (`{vault://gcp/...}`)
> - **HashiCorp Vault** (`{vault://hcv/...}`)
> 
> The reference syntax follows the same principle. This allows migrating from a local environment (using environment variables) to a production environment (connected to HashiCorp or AWS) without needing to alter a single line of the APIs' declarative configuration.

## Practical Lab

In this exercise, we will protect an API Key that we need to send to our backend (upstream), using the native environment variable-based Vault.

### Step 1: Configure the Secret in the Environment
For the native environment variable Vault (`env`), we must export the variable in the operating system or container before starting Kong. The default prefix Kong inspects is `KONG_VAULT_ENV_`.

```bash
export KONG_VAULT_ENV_BACKEND_API_KEY="super-secret-key-12345"
```
*(Restart Kong if you are applying this to a running instance).*

### Step 2: Reference the Secret in a Plugin
Suppose we want to use the `request-transformer` plugin to inject this API Key into the request headers before it reaches our backend, but we don't want the key to be visible in our YAML configuration.

We configure the plugin using the Vault reference syntax:

```yaml
plugins:
  - name: request-transformer
    config:
      add:
        headers:
          - "x-api-key:{vault://env/backend_api_key}"
```

### Step 3: Flow Validation
1. Make a normal GET request to your API through the Gateway.
2. Kong will process the request, invoke the plugin, dynamically resolve the reference `{vault://env/backend_api_key}`, and replace the string with the actual value `super-secret-key-12345` which is securely held in memory.
3. Verify (using a service like httpbin or by checking the upstream logs) that the backend receives the request with the header successfully injected: `x-api-key: super-secret-key-12345`.