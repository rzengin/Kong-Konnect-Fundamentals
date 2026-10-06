#!/usr/bin/env python3
"""Traduce las páginas del curso (español) a inglés o portugués con Gemini.

Cada página del sitio existe en tres variantes (mkdocs-static-i18n, estructura
"suffix"):  pagina.md (es, fuente)  ·  pagina.en.md  ·  pagina.pt.md

Uso (desde la raíz del repositorio):

    pip install google-genai
    export GEMINI_API_KEY=...            # o ejecutar `kong-env`
    python scripts/translate_docs.py --lang en              # todas las páginas sin traducción
    python scripts/translate_docs.py --lang pt docs/index.md  # solo esas páginas
    python scripts/translate_docs.py --lang en --force docs/dia-2-labs/Lab_07_Observabilidad_Avanzada.md

Por defecto NO sobrescribe traducciones existentes (use --force). Revise
siempre el resultado antes de commitear: bloques de código, rutas y nombres de
productos deben quedar intactos.
"""
import argparse
import os
import sys
from pathlib import Path

LANG_NAMES = {"en": "English", "pt": "Brazilian Portuguese"}
DOCS_DIR = Path("docs")
MODEL = os.environ.get("GEMINI_MODEL", "gemini-2.5-flash")


def source_pages(paths):
    if paths:
        return [Path(p) for p in paths]
    return sorted(
        p for p in DOCS_DIR.rglob("*.md")
        if not (p.name.endswith(".en.md") or p.name.endswith(".pt.md"))
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--lang", choices=sorted(LANG_NAMES), default="en", help="idioma destino (default: en)")
    parser.add_argument("--force", action="store_true", help="sobrescribir traducciones existentes")
    parser.add_argument("files", nargs="*", help="páginas .md en español a traducir (default: todas)")
    args = parser.parse_args()

    # La API key de Gemini se lee del entorno (la define kong-env: GEMINI_API_KEY). Nunca se imprime.
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        sys.exit("Error: falta la variable de entorno GEMINI_API_KEY. "
                 "Ejecute 'kong-env' o exporte GEMINI_API_KEY antes de correr este script.")

    from google import genai
    from google.genai import types

    client = genai.Client(api_key=api_key)
    target = LANG_NAMES[args.lang]
    prompt = (f"You are a technical translator. Translate the following Markdown document from Spanish to {target}. "
              "Preserve all Markdown formatting (heading levels, admonitions, tables), code blocks, frontmatter, "
              "file paths, URLs and links exactly as they are. Do not translate product names (Kong, Konnect, decK, "
              "OpenObserve, Phoenix) nor acronyms such as OAS, OIDC, ACL. Return only the translated Markdown.")

    pages = source_pages(args.files)
    print(f"{len(pages)} página(s) fuente; idioma destino: {args.lang}")
    for src in pages:
        dst = src.with_name(src.name[:-3] + f".{args.lang}.md")
        if dst.exists() and not args.force:
            print(f"  = {dst} ya existe (use --force para regenerar)")
            continue
        print(f"  → {src} → {dst} ...", end="", flush=True)
        try:
            response = client.models.generate_content(
                model=MODEL,
                contents=[prompt, src.read_text(encoding="utf-8")],
                config=types.GenerateContentConfig(temperature=0.1),
            )
            dst.write_text(response.text, encoding="utf-8")
            print(" ok")
        except Exception as exc:  # noqa: BLE001 - informar y seguir con la siguiente página
            print(f" error: {exc}")


if __name__ == "__main__":
    main()
