# ITSM Integration (Alerts and Ticketing)

## Objective
Demonstrate how Kong can trigger the automatic creation of incidents in ITSM tools (ServiceNow/Jira) in a standard way and independently of Datadog.

## Theoretical Content
In distributed and microservices-oriented architectures, observability and incident response are critical. Kong Gateway sits at the edge of the network, allowing it to have complete visibility into the traffic flowing to APIs. Leveraging this privileged position, Kong can detect anomalies, such as an unusual increase in the error rate (e.g., HTTP 5xx status codes), and immediately notify corporate IT Service Management (ITSM) systems, such as ServiceNow or Jira Service Management.

### Architecture Flow
1.  **Detection in Kong:** Kong processes traffic and, by using plugins (such as `http-log` or `pre-function`), evaluates the status of responses.
2.  **Alert Trigger:** Upon detecting an error condition (e.g., an HTTP 500), the configured plugin makes an asynchronous call.
3.  **Webhook Sending:** A generic Webhook with JSON format is sent to the ITSM system's endpoint.
4.  **Ticket Creation:** The ITSM system receives the JSON payload, parses it, and automatically generates an incident ticket, assigning it to the corresponding team for prompt resolution.

## Practical Lab

In this lab, we will configure the `http-log` plugin to send a JSON payload simulating the creation of a ticket in an ITSM system upon a 5xx error.

### Step 1: Configure the `http-log` plugin
We will add the plugin to our route or service to send logs to a simulated endpoint (example: a webhook from [webhook.site](https://webhook.site)).

```yaml
plugins:
  - name: http-log
    config:
      http_endpoint: "https://webhook.site/tu-id-de-webhook-aqui"
      method: "POST"
      timeout: 10000
      keepalive: 60000
      flush_timeout: 2
      retry_count: 10
      custom_fields_by_lua:
        ticket_info: |
          return {
            title = "API Alert: " .. kong.request.get_path(),
            description = "An error " .. kong.response.get_status() .. " was detected in the service.",
            priority = "High"
          }
```
*Note: In a real environment, you can use a `serverless` plugin (such as `pre-function`) to have more granular control, executing Lua code that only sends the webhook if the status code is `> 499` and structuring the payload exactly as required by the ServiceNow or Jira API.*

### Step 2: Test the Flow
1.  Generate a forced error in your API. For this lab, assuming you have a route pointing to a test service like `httpbin.org`, we can force an HTTP 500 error by calling the `/status/500` endpoint. Execute this command in your terminal:

    ```bash
    curl -i http://localhost:8000/mock/status/500
    ```
    *(Make sure to replace `/mock` with the actual route you configured in Kong).*

2.  Observe how Kong receives the HTTP 500 from the backend, captures the event, and automatically executes the plugin.
3.  Verify in the receiving Webhook console (e.g., webhook.site) that a POST request has been received. Within the request body (JSON payload), you will be able to see the incident data ready to be consumed by the ITSM, similar to this:

    ```json
    {
      "latencies": { "proxy": 140, "kong": 12, "request": 152 },
      "request": { "uri": "/mock/status/500", "method": "GET" },
      "response": { "status": 500 },
      "ticket_info": {
        "title": "API Alert: /mock/status/500",
        "description": "An error 500 was detected in the service.",
        "priority": "High"
      }
    }
    ```