import sys
import os
import re

def process_file(file_path, project_name, project_root):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        return

    new_content = content
    imports_found = re.findall(r"import\s+('|")package:" + project_name + r"/(.*)('|");", content)

    if not imports_found:
        return

    for quote1, import_path, quote2 in imports_found:
        full_import_path = os.path.join(project_root, 'lib', import_path.replace('/', os.sep))
        current_dir = os.path.dirname(file_path)
        relative_path = os.path.relpath(full_import_path, current_dir)
        relative_path = relative_path.replace(os.sep, '/')

        old_import = f"import {quote1}package:{project_name}/{import_path}{quote2};"
        new_import = f"import {quote1}{relative_path}{quote2};"
        
        new_content = new_content.replace(old_import, new_import)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"Processed: {file_path}")

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python mass_replace.py <project_name> <project_root> <file1> <file2> ...")
        sys.exit(1)

    project_name = sys.argv[1]
    project_root = sys.argv[2]
    files_to_process = sys.argv[3:]

    for file_path in files_to_process:
        process_file(file_path, project_name, project_root)

    print("Import path conversion finished.")
