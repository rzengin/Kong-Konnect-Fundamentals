import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    original_content = content
    
    # Fix jq -n --arg cert "$CERT" '{cert: $cert}'
    # replacement: python3 -c 'import sys, json; print(json.dumps({"cert": sys.argv[1]}))' "$CERT"
    content = content.replace("jq -n --arg cert \"$CERT\" '{cert: $cert}'", "python3 -c 'import sys, json; print(json.dumps({\"cert\": sys.argv[1]}))' \"$CERT\"")
    
    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, _, files in os.walk('.'):
    if 'node_modules' in root or '.git' in root or '.venv' in root:
        continue
    for file in files:
        if file.endswith('.sh'):
            process_file(os.path.join(root, file))

