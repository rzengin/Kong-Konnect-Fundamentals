import os
import glob
import time
from deep_translator import GoogleTranslator
from deep_translator.exceptions import TranslationNotFound

def safe_translate(translator, text, retries=3):
    if not text.strip():
        return text
    for i in range(retries):
        try:
            return translator.translate(text)
        except Exception as e:
            print(f"Error traduciendo (intento {i+1}): {e}")
            time.sleep(2 * (i + 1))
    # Si falla, devolver el texto original
    return text

def translate_markdown(file_path):
    dir_name = os.path.dirname(file_path)
    base_name = os.path.basename(file_path)
    new_name = base_name.replace('.md', '.pt.md')
    new_path = os.path.join(dir_name, new_name)
    
    if os.path.exists(new_path):
        print(f"Omitiendo {file_path}, ya está traducido.")
        return

    print(f"Traduciendo {file_path}...")
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    translator = GoogleTranslator(source='es', target='pt')
    translated_lines = []
    chunk = ""
    in_code_block = False

    for line in lines:
        if line.strip().startswith("```"):
            if chunk:
                translated_lines.append(safe_translate(translator, chunk))
                chunk = ""
            in_code_block = not in_code_block
            translated_lines.append(line)
            continue

        if in_code_block:
            translated_lines.append(line)
        else:
            # Reducimos el tamaño del chunk a 2000 caracteres para ser más seguros con la API
            if len(chunk) + len(line) < 2000:
                chunk += line
            else:
                translated_lines.append(safe_translate(translator, chunk) + "\n")
                chunk = line

    if chunk:
        translated_lines.append(safe_translate(translator, chunk) + "\n")

    dir_name = os.path.dirname(file_path)
    base_name = os.path.basename(file_path)
    new_name = base_name.replace('.md', '.pt.md')
    new_path = os.path.join(dir_name, new_name)

    final_text = "".join(translated_lines)
    final_text = final_text.replace("##", "## ")
    final_text = final_text.replace("##  ", "## ")
    final_text = final_text.replace("###", "### ")
    final_text = final_text.replace("###  ", "### ")
    
    with open(new_path, 'w', encoding='utf-8') as f:
        f.write(final_text)
    print(f"Guardado {new_path}")
    time.sleep(1) # Pequeña pausa entre archivos

def main():
    md_files = [f for f in glob.glob("docs/**/*.md", recursive=True) if not f.endswith(".pt.md")]
    for file in md_files:
        translate_markdown(file)

if __name__ == "__main__":
    main()
