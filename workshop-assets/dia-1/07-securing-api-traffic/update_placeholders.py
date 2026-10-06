import re

with open('Guia_Paso_a_Paso_Manual.md', 'r') as f:
    content = f.read()

def replace_placeholder(match):
    alt_text = match.group(1)
    img_path = match.group(2)
    return f'> 📸 **[CAPTURA DE PANTALLA REQUERIDA]** Toma captura de "{alt_text}" y guárdala como: `{img_path}`'

new_content = re.sub(r'!\[([^\]]+)\]\((images/[^)]+)\)', replace_placeholder, content)

with open('Guia_Paso_a_Paso_Manual.md', 'w') as f:
    f.write(new_content)
