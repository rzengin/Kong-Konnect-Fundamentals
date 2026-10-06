import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    original_content = content
    
    # Replace "Esperando Xs..." with "Esperando 15s..."
    content = re.sub(r'Esperando \d+s', 'Esperando 15s', content)
    # This is a bit risky for run_all_demos.sh, let's just do it carefully.
    content = re.sub(r'sleep 5', 'sleep 15', content)
    content = re.sub(r'sleep 10', 'sleep 15', content)
    
    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

for file in ['run_all_demos.sh', 'run_all_labs.sh']:
    if os.path.exists(file):
        process_file(file)

