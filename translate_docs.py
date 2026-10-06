import os
from google import genai
from google.genai import types
from pathlib import Path

# La API key de Gemini se lee del entorno (la define kong-env: GEMINI_API_KEY)
api_key = os.environ.get("GEMINI_API_KEY")
if not api_key:
    print("Error: falta la variable de entorno GEMINI_API_KEY. "
          "Ejecute 'kong-env' o exporte GEMINI_API_KEY antes de correr este script.")
    exit(1)

client = genai.Client(api_key=api_key)

docs_dir = Path("docs")
files_to_translate = []

# Collect all base markdown files (not ending in .pt.md or .en.md)
for root, _, files in os.walk(docs_dir):
    for file in files:
        if file.endswith(".md") and not file.endswith(".pt.md") and not file.endswith(".en.md"):
            files_to_translate.append(Path(root) / file)

print(f"Found {len(files_to_translate)} files to translate.")

def translate_markdown(content: str) -> str:
    response = client.models.generate_content(
        model='gemini-2.5-flash',
        contents=[
            "You are a technical translator. Translate the following Markdown document from Spanish to English. Preserve all Markdown formatting, code blocks, frontmatter, and links exactly as they are.",
            content
        ],
        config=types.GenerateContentConfig(
            temperature=0.1,
        )
    )
    return response.text

for file_path in files_to_translate:
    # Target path: just add .en before .md
    target_path = file_path.with_suffix('.en.md')
    
    if target_path.exists():
        print(f"Skipping {target_path}, already exists.")
        continue
    
    print(f"Translating {file_path} to {target_path} ...", end="", flush=True)
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
            
        translated_content = translate_markdown(content)
        
        with open(target_path, "w", encoding="utf-8") as f:
            f.write(translated_content)
        print(" Done.")
    except Exception as e:
        print(f" Error: {e}")

print("Translation process finished.")
