import os
import re
import glob

project_root = "c:\\markit_place_front"
project_name = "markit_place_front"

file_paths = glob.glob(os.path.join(project_root, 'lib', '**', '*.dart'), recursive=True)

for file_path in file_paths:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        continue

    new_content = content
    imports_found = re.findall(r"import\s+('|`)package:" + project_name + r"/(.*)('|\");", content)

    if not imports_found:
        continue

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

print("Import path conversion finished.")
