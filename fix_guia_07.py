import re

with open("docs/dia-1-teoria-y-demos/07-securing-api-traffic/Guia_07_Securing_API_Traffic.md", "r") as f:
    content = f.read()

content = re.sub(
r"""    Usando curl:
    ```bash
    curl -k -i --cert client.crt --key client.key \\
    ```bash
    curl -k -i -X POST --cert client.crt --key client.key \\
      https://localhost:8443/mock \\
      -H "Authorization: Bearer \$ACCESS_TOKEN" \\
      -d '\{"message": "hola OIDC"\}'   
    ```""", 
r"""    ```bash
    curl -k -i --cert client.crt --key client.key \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      https://localhost:8443/mock
    ```""", content)

with open("docs/dia-1-teoria-y-demos/07-securing-api-traffic/Guia_07_Securing_API_Traffic.md", "w") as f:
    f.write(content)

