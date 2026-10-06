import glob
import re

for filepath in glob.glob("docs/dia-2-labs/*.md"):
    with open(filepath, "r") as f:
        content = f.read()
        
    # Find "**Analizando el resultado:**\n-" or "**Analizando el resultado:**\n\r-"
    # and replace with "**Analizando el resultado:**\n\n-"
    new_content = re.sub(r'\*\*Analizando el resultado:\*\*\n-', '**Analizando el resultado:**\n\n-', content)
    
    # Also for any bold text followed immediately by a bullet point
    new_content = re.sub(r'(\*\*[^\*]+\*\*)\n-', r'\1\n\n-', new_content)
    
    if new_content != content:
        with open(filepath, "w") as f:
            f.write(new_content)
        print(f"Fixed {filepath}")

