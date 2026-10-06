import glob
import re

for filepath in glob.glob("docs/**/*.md", recursive=True):
    with open(filepath, "r") as f:
        lines = f.readlines()
        
    for i in range(1, len(lines)):
        # If current line starts with "- " and previous line has text but is not a bullet and not empty
        curr = lines[i].strip()
        prev = lines[i-1].strip()
        
        if curr.startswith("- ") and prev and not prev.startswith("- ") and not prev.startswith("#") and not prev.endswith(":") and not prev.endswith("```") and not prev.startswith(">"):
            print(f"Possible missing newline before list in {filepath}:{i+1}")
            print(f"  Prev: {prev}")
            print(f"  Curr: {curr}")

