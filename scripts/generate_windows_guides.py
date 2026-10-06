#!/usr/bin/env python3
"""
Genera versiones Windows-only de las guías Markdown y luego genera PDFs
para ambas versiones (completa y Windows-only).

Patrones detectados en las guías:
1. Bloques separados:
   **Para Mac/Linux:**
   ```text
   <comandos mac>
   ```
   
   **Para Windows (CMD):**
   ```text
   <comandos windows>
   ```

2. Bloques combinados con comentarios:
   ```text
   # Para Mac/Linux
   <comando mac>
   
   # Para Windows (CMD)
   <comando windows>
   ```

3. Líneas inline:
   > * **En Mac/Linux:** `comando`
   > * **En Windows:** `comando`
"""

import re
import sys
import os

def generate_windows_only(input_path, output_path):
    """Genera una versión Windows-only de la guía Markdown."""
    
    with open(input_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    output_lines = []
    i = 0
    skip_mac_block = False
    in_combined_block = False
    combined_block_lines = []
    
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        
        # ============================================================
        # PATRÓN 1: Bloques separados **Para Mac/Linux:** seguido de
        #           **Para Windows (CMD):**
        # ============================================================
        if re.match(r'\*\*Para Mac/Linux.*\*\*:?', stripped) or \
           re.match(r'>\s*\*\*Para Mac/Linux.*\*\*:?', stripped):
            # Check if a Windows block follows (scan ahead)
            j = i + 1
            # Skip the Mac code block
            in_code = False
            while j < len(lines):
                sj = lines[j].strip()
                if sj.startswith('```') and not in_code:
                    in_code = True
                    j += 1
                    continue
                elif sj.startswith('```') and in_code:
                    in_code = False
                    j += 1
                    continue
                elif not in_code and (
                    re.match(r'\*\*Para Windows.*\*\*:?', sj) or
                    re.match(r'>\s*\*\*Para Windows.*\*\*:?', sj)
                ):
                    # Found Windows block - skip the Mac block entirely
                    # Output only from the Windows block onward
                    i = j  # Jump to the Windows block
                    break
                elif not in_code and sj and not sj.startswith('>'):
                    # Non-empty, non-blockquote line that's not Windows = no pair found
                    break
                j += 1
            else:
                # No Windows block found - commands are cross-platform
                # Drop the Mac/Linux label entirely (guide is Windows-only)
                i += 1
                continue
            
            # Check: did we find Windows (i == j means we jumped) or break out?
            if i != j:
                # Broke out of loop without finding Windows block
                # Drop the Mac/Linux label entirely
                i += 1
                continue
            # Found Windows block - skip its label line too
            # (the guide is Windows-only, so "Para Windows (CMD):" is redundant)
            i += 1
            continue
        # ============================================================
        # PATRÓN 1.5: Standalone **Para Windows (CMD/PowerShell):** labels
        # These appear without a preceding Mac/Linux block
        # ============================================================
        if re.match(r'\*\*Para Windows.*\*\*:?', stripped) or \
           re.match(r'>\s*\*\*Para Windows.*\*\*:?', stripped):
            # Skip this label line entirely
            i += 1
            continue
        
        # ============================================================
        # PATRÓN 2: Bloques combinados con comentarios dentro de ```
        # ============================================================
        if stripped.startswith('```') and not in_combined_block:
            # Look ahead to see if this block contains "# Para Mac" and "# Para Windows"
            j = i + 1
            has_mac = False
            has_windows = False
            block_end = -1
            while j < len(lines):
                sj = lines[j].strip()
                if sj.startswith('```'):
                    block_end = j
                    break
                if re.match(r'#\s*Para Mac', sj):
                    has_mac = True
                if re.match(r'#\s*Para Windows', sj):
                    has_windows = True
                j += 1
            
            if has_mac and has_windows and block_end > 0:
                # Extract only Windows commands from the combined block
                output_lines.append(line)  # Opening ```
                j = i + 1
                skip_section = False
                while j < block_end:
                    sj = lines[j].strip()
                    if re.match(r'#\s*Para Mac', sj) or re.match(r'#\s*Para Linux', sj):
                        skip_section = True
                        j += 1
                        continue
                    elif re.match(r'#\s*Para Windows', sj):
                        skip_section = False
                        # Skip the Windows comment line too (redundant in Windows-only guide)
                        j += 1
                        continue
                    
                    if not skip_section:
                        output_lines.append(lines[j])
                    j += 1
                
                output_lines.append(lines[block_end])  # Closing ```
                i = block_end + 1
                continue
        
        # ============================================================
        # PATRÓN 3: Líneas inline con > * **En Mac/Linux:**
        # ============================================================
        if re.match(r'>\s*\*\s*\*\*En Mac/Linux.*\*\*:', stripped) or \
           re.match(r'>\s*\*\s*\*\*En Mac.*\*\*:', stripped):
            # Skip this line (Mac inline)
            i += 1
            continue
        
        if re.match(r'>\s*\*\s*\*\*En Windows.*\*\*:', stripped):
            # Remove the label, keep just the command part
            # Extract the command from backticks if present
            cmd_match = re.search(r'`([^`]+)`', line)
            if cmd_match:
                output_lines.append(f"> `{cmd_match.group(1)}`\n")
            else:
                output_lines.append(line)
            i += 1
            continue
        
        # ============================================================
        # Default: keep the line
        # ============================================================
        output_lines.append(line)
        i += 1
    
    # Update the title to indicate Windows version
    content = ''.join(output_lines)
    # Add "(Windows)" to the main title
    content = re.sub(
        r'(# .*Guía Paso a Paso.*)',
        r'\1 — Versión Windows',
        content,
        count=1
    )
    # If no match, try the first H1
    if '— Versión Windows' not in content:
        content = re.sub(
            r'^(# .+)$',
            r'\1 — Versión Windows',
            content,
            count=1,
            flags=re.MULTILINE
        )
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"  ✅ Generado: {output_path}")
    return output_path


def main():
    guides = [
        ("ejercicio-000/Guia_Paso_a_Paso_000.md", "ejercicio-000/Guia_Paso_a_Paso_000_Windows.md"),
        ("ejercicio-001/Guia_Paso_a_Paso_001.md", "ejercicio-001/Guia_Paso_a_Paso_001_Windows.md"),
        ("ejercicio-002/Guia_Paso_a_Paso_002.md", "ejercicio-002/Guia_Paso_a_Paso_002_Windows.md"),
        ("ejercicio-003/Guia_Paso_a_Paso_003.md", "ejercicio-003/Guia_Paso_a_Paso_003_Windows.md"),
        ("ejercicio-004/Guia_Paso_a_Paso_Solucion_004.md", "ejercicio-004/Guia_Paso_a_Paso_Solucion_004_Windows.md"),
    ]
    
    print("=" * 60)
    print(" Generando versiones Windows-only de las guías")
    print("=" * 60)
    
    for src, dst in guides:
        if os.path.exists(src):
            generate_windows_only(src, dst)
        else:
            print(f"  ⚠️ No encontrado: {src}")
    
    print("\n✅ Todas las versiones Windows generadas.")
    print("   Ahora genera los PDFs con: npx md-to-pdf <archivo>.md")


if __name__ == "__main__":
    main()
