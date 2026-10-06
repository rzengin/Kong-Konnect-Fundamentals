import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    original_content = content
    
    # 1. Remove "| jq" from curl commands
    content = re.sub(r'(\|\s*jq\b)', '', content)
    
    # 2. In Prerequisitos, remove jq from brew/apt installs and table
    content = re.sub(r'\s*\|\s*jq\s*\|.*?\|.*?\|\n', '\n', content) # table row
    content = re.sub(r'brew install (.*?)jq(.*?)\n', r'brew install \1\2\n', content)
    content = re.sub(r'apt-get install -y(.*?)jq(.*?)\n', r'apt-get install -y\1\2\n', content)
    content = re.sub(r'jq --version.*?\n', '', content)
    content = re.sub(r'- jq: https://jqlang\.org/.*?\n', '', content)
    
    # 3. In Lab_00_Setup_Local.md, remove jq
    content = re.sub(r'- \*\*cURL\*\* y \*\*jq\*\*', '- **cURL**', content)
    content = re.sub(r'\(como `decK` y `jq`\)', '(como `decK`)', content)
    
    # 4. In Guia_00_Arquitectura_y_Setup.md
    content = re.sub(r'\(Docker, decK, jq\)', '(Docker, decK)', content)
    content = re.sub(r', utilizando `jq` para formatear el JSON pero', ' y', content)
    content = re.sub(r'\(usando `jq` para el JSON y enviando headers a stderr\)', '(enviando headers a stderr)', content)
    
    # 5. Fix jq -Rs in shell scripts/markdown
    # export DECK_MTLS_CA_CERT=$(jq -Rs . < ca.crt) -> export DECK_MTLS_CA_CERT=$(python3 -c 'import sys, json; print(json.dumps(sys.stdin.read()))' < ca.crt)
    content = re.sub(r'jq -Rs \. < ([^\)]+)', r"python3 -c 'import sys, json; print(json.dumps(sys.stdin.read()))' < \1", content)
    
    # 6. Fix docker network inspect | jq -> docker network inspect --format
    content = re.sub(r'docker network inspect kong-workshop \| jq -r \'\.\[0\]\.IPAM\.Config\[0\]\.Gateway\'', r"docker network inspect kong-workshop --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}'", content)
    
    if content != original_content:
        # Fix any double spaces in apt/brew
        content = content.replace("  ", " ")
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, _, files in os.walk('.'):
    if 'node_modules' in root or '.git' in root or '.venv' in root:
        continue
    for file in files:
        if file.endswith('.md') or file.endswith('.sh'):
            process_file(os.path.join(root, file))

