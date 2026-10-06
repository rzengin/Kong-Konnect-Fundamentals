# Gestión de Secretos (Kong Vaults)

## Objetivo
Mostrar cómo proteger información sensible mediante Gestión Centralizada de Secretos utilizando Kong Vaults.

## Contenido Teórico
La gestión de información confidencial, como claves API, contraseñas de bases de datos, certificados y tokens, es un pilar fundamental en la seguridad de cualquier infraestructura moderna. Configurar estas credenciales en texto plano dentro de archivos declarativos (YAML/JSON) o bases de datos expone a la organización a graves riesgos de seguridad.

Kong Gateway soluciona este problema de manera elegante mediante su funcionalidad de **Vaults**. Los Vaults permiten almacenar, gestionar y acceder a secretos de forma segura. En lugar de escribir el secreto real en la configuración de un plugin, se utiliza una referencia al Vault (como un puntero). En tiempo de ejecución, Kong resuelve dinámicamente esta referencia y obtiene el valor real del secreto en memoria, sin escribirlo en logs ni exponerlo a través de la API de administración.

> [!INFO]
> **Extensibilidad y Estándar Empresarial**
> 
> En este ejercicio utilizaremos el Vault interno nativo de Kong (`env`) para mantenerlo simple. Sin embargo, es vital destacar que **este mismo estándar de referencias se utiliza de forma totalmente transparente para integrarse con Vaults externos corporativos**.
> 
> Kong soporta de forma nativa la integración con:
> - **AWS Secrets Manager** (`{vault://aws/...}`)
> - **GCP Secret Manager** (`{vault://gcp/...}`)
> - **HashiCorp Vault** (`{vault://hcv/...}`)
> 
> La sintaxis de referencia sigue el mismo principio. Esto permite migrar de un entorno local (usando variables de entorno) a un entorno de producción (conectado a HashiCorp o AWS) sin necesidad de alterar una sola línea de la configuración declarativa de las APIs.

## Laboratorio Práctico

En este ejercicio protegeremos una API Key que necesitamos enviar a nuestro backend (upstream), usando el Vault nativo basado en variables de entorno.

### Paso 1: Configurar el Secreto en el Entorno
Para el Vault nativo de variables de entorno (`env`), debemos exportar la variable en el sistema operativo o contenedor antes de iniciar Kong. El prefijo predeterminado que Kong inspecciona es `KONG_VAULT_ENV_`.

```bash
export KONG_VAULT_ENV_BACKEND_API_KEY="super-secret-key-12345"
```
*(Reinicia Kong si estás aplicando esto en una instancia en ejecución).*

### Paso 2: Referenciar el Secreto en un Plugin
Supongamos que queremos usar el plugin `request-transformer` para inyectar esta API Key en los headers de la petición antes de que llegue a nuestro backend, pero no queremos que la clave quede visible en nuestra configuración YAML.

Configuramos el plugin utilizando la sintaxis de referencia al Vault:

```yaml
plugins:
  - name: request-transformer
    config:
      add:
        headers:
          - "x-api-key:{vault://env/backend_api_key}"
```

### Paso 3: Validación del Flujo
1. Realiza una petición GET normal hacia tu API a través del Gateway.
2. Kong procesará la petición, invocará el plugin, resolverá dinámicamente la referencia `{vault://env/backend_api_key}` y sustituirá la cadena por el valor real `super-secret-key-12345` que se encuentra seguro en memoria.
3. Comprueba (usando un servicio tipo httpbin o revisando los logs del upstream) que el backend recibe la petición con el header inyectado exitosamente: `x-api-key: super-secret-key-12345`.
