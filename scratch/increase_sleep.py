import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    original_content = content
    
    # Replace "Esperando Xs..." with "Esperando 15s..."
    content = re.sub(r'Esperando \d+s para que Konnect', 'Esperando 15s para que Konnect', content)
    # Replace "sleep X" with "sleep 15"
    content = re.sub(r'sleep \d+ &&', 'sleep 15 &&', content)
    
    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, _, files in os.walk('docs/dia-2-labs'):
    for file in files:
        if file.endswith('.md'):
            process_file(os.path.join(root, file))

