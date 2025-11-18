# Обновление размеров файлов

## Выполните эту команду для обновления всех размеров:

```bash
cd "/Users/macbookpro/Git Actions/flutter-opad"
python3 scripts/update_all_file_sizes.py
```

Или выполните напрямую:

```bash
cd "/Users/macbookpro/Git Actions/flutter-opad"
python3 -c "
import os
import re
from pathlib import Path

target = Path('web/assets/uploads')
sizes = {}

for root, dirs, files in os.walk(target):
    for f in files:
        if f.lower().endswith(('.pdf', '.doc', '.docx')):
            fp = Path(root) / f
            rel = str(fp.relative_to(target))
            sizes[rel] = fp.stat().st_size

with open('lib/data/uploaded_files_data.dart', 'r', encoding='utf-8') as f:
    content = f.read()

updated = 0
for path, size in sizes.items():
    pattern = rf\"path:\\s*'{re.escape(path)}',\\s*type:\\s*'[^']+',\\s*size:\\s*\\d+\"
    replacement = f\"path: '{path}',\n      type: '{'pdf' if path.lower().endswith('.pdf') else ('docx' if path.lower().endswith('.docx') else 'doc')}',\n      size: {size}\"
    new_content = re.sub(pattern, replacement, content)
    if new_content != content:
        content = new_content
        updated += 1

with open('lib/data/uploaded_files_data.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print(f'Updated {updated} file sizes')
"
```

## После обновления:

1. Перезапустите приложение: `flutter run -d chrome`
2. Откройте страницу "Файли"
3. Все файлы будут отображаться с правильными размерами

