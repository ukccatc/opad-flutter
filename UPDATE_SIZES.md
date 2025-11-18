# Обновление размеров файлов

## После копирования файлов выполните:

```bash
cd "/Users/macbookpro/Git Actions/flutter-opad"
python3 scripts/update_file_sizes.py
```

Этот скрипт:
1. Проверит наличие файлов в `web/assets/uploads/`
2. Обновит размеры в `lib/data/uploaded_files_data.dart` на основе реальных файлов
3. Покажет статистику обновленных файлов

## Или выполните полный процесс:

```bash
# 1. Скопировать файлы
python3 scripts/copy_uploads.py

# 2. Обновить размеры
python3 scripts/update_file_sizes.py

# 3. Перезапустить приложение
flutter run -d chrome
```

## Размеры отображаются автоматически

После обновления размеры будут отображаться на экране в формате:
- `B` - байты (если < 1 KB)
- `KB` - килобайты (если < 1 MB)
- `MB` - мегабайты (если >= 1 MB)

Примеры:
- `245.3 KB`
- `1.2 MB`
- `512 B`

