import glob
import re

def main():
    md_files = glob.glob("docs/**/*.pt.md", recursive=True)
    count = 0
    for filepath in md_files:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Replace occurrences of any non-whitespace character right before ``` with double newline
        # Also, replacing just non-newline characters before ``` is enough, because the problem is when there's no newline at all.
        # So we look for any character that is NOT a newline, immediately followed by ```
        # r'([^\n])```' -> r'\1\n\n```'
        new_content = re.sub(r'([^\n])```', r'\1\n\n```', content)
        
        if new_content != content:
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(new_content)
            print(f"Fixed {filepath}")
            count += 1
    
    print(f"Total files fixed: {count}")

if __name__ == "__main__":
    main()
