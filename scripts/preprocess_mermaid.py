#!/usr/bin/env python3
"""
preprocess_mermaid.py
Pre-procesa archivos Markdown reemplazando bloques ```mermaid``` con imágenes PNG.
Usa mmdc (mermaid-cli) para renderizar los diagramas.

Uso:
    python3 scripts/preprocess_mermaid.py input.md output.md [--img-dir dir]
    
Los PNGs se guardan en un subdirectorio .mermaid-imgs/ junto al archivo de salida.
"""

import re
import os
import sys
import subprocess
import hashlib
import tempfile


def render_mermaid(mermaid_code, output_png, mmdc_path="mmdc"):
    """Renderiza código Mermaid a PNG usando mmdc."""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.mmd', delete=False) as f:
        f.write(mermaid_code)
        mmd_file = f.name
    
    try:
        result = subprocess.run(
            [mmdc_path, '-i', mmd_file, '-o', output_png,
             '-b', 'white', '-t', 'default', '-s', '2'],
            capture_output=True, text=True, timeout=30
        )
        if result.returncode != 0:
            print(f"    ⚠️ mmdc error: {result.stderr[:200]}", file=sys.stderr)
            return False
        return os.path.exists(output_png)
    except subprocess.TimeoutExpired:
        print(f"    ⚠️ mmdc timeout", file=sys.stderr)
        return False
    except FileNotFoundError:
        print(f"    ❌ mmdc not found at: {mmdc_path}", file=sys.stderr)
        return False
    finally:
        os.unlink(mmd_file)


def preprocess_markdown(input_path, output_path, img_dir=None, mmdc_path="mmdc"):
    """
    Lee un archivo Markdown, encuentra bloques ```mermaid```,
    los renderiza a PNG y los reemplaza con ![diagram](path.png).
    """
    with open(input_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Determinar directorio de imágenes
    if img_dir is None:
        base_dir = os.path.dirname(os.path.abspath(input_path))
        img_dir = os.path.join(base_dir, '.mermaid-imgs')
    
    os.makedirs(img_dir, exist_ok=True)
    
    # Encontrar todos los bloques mermaid
    pattern = re.compile(r'```mermaid\s*\n(.*?)\n```', re.DOTALL)
    matches = list(pattern.finditer(content))
    
    if not matches:
        # No mermaid blocks, just copy
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return 0
    
    print(f"  🔄 {os.path.basename(input_path)}: {len(matches)} diagramas")
    
    # Reemplazar cada bloque
    offset = 0
    rendered = 0
    new_content = content
    
    for i, match in enumerate(matches):
        mermaid_code = match.group(1).strip()
        
        # Generar nombre único basado en hash del contenido
        code_hash = hashlib.md5(mermaid_code.encode()).hexdigest()[:8]
        basename = os.path.splitext(os.path.basename(input_path))[0]
        png_name = f"{basename}_diagram_{i+1}_{code_hash}.png"
        png_path = os.path.join(img_dir, png_name)
        
        # Renderizar solo si no existe o el contenido cambió
        if not os.path.exists(png_path):
            success = render_mermaid(mermaid_code, png_path, mmdc_path)
            if success:
                rendered += 1
                print(f"    ✅ Diagrama {i+1}/{len(matches)}")
            else:
                print(f"    ❌ Diagrama {i+1}/{len(matches)} falló")
                continue
        else:
            rendered += 1
        
        # Reemplazar el bloque mermaid con la imagen
        # Usar ruta relativa desde el directorio del output
        rel_path = os.path.relpath(png_path, os.path.dirname(os.path.abspath(output_path)))
        img_tag = f"![Diagrama {i+1}]({rel_path})"
        new_content = new_content.replace(match.group(0), img_tag, 1)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    return rendered


def main():
    if len(sys.argv) < 3:
        print(f"Uso: {sys.argv[0]} input.md output.md [--mmdc path]")
        sys.exit(1)
    
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    
    mmdc_path = "mmdc"
    if "--mmdc" in sys.argv:
        idx = sys.argv.index("--mmdc")
        mmdc_path = sys.argv[idx + 1]
    
    rendered = preprocess_markdown(input_path, output_path, mmdc_path=mmdc_path)
    print(f"  📊 {rendered} diagramas renderizados")


if __name__ == "__main__":
    main()
