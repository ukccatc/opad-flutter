# 🔧 Исправление ошибки Firebase

## Проблема
```
Error: Invalid project id: YOUR_PROJECT_ID
```

## Решение

### Способ 1: Выбрать существующий проект (Рекомендуется)

1. **Посмотрите список проектов:**
   ```bash
   firebase projects:list
   ```

2. **Выберите проект интерактивно:**
   ```bash
   firebase use --add
   ```
   - Выберите проект из списка
   - Введите алиас: `default`
   - Файл `.firebaserc` обновится автоматически

3. **Или укажите проект напрямую:**
   ```bash
   firebase use YOUR_PROJECT_ID
   ```

### Способ 2: Создать новый проект

1. **Откройте Firebase Console:**
   https://console.firebase.google.com/

2. **Создайте проект:**
   - Нажмите "Add project" или "Создать проект"
   - Введите название (например: `opad-web`)
   - Следуйте инструкциям

3. **Свяжите проект с локальной директорией:**
   ```bash
   firebase use --add
   ```
   Выберите созданный проект

### Способ 3: Инициализировать заново

```bash
cd "/Users/macbookpro/Git Actions/flutter-opad"
firebase init hosting
```

Выберите:
- ✅ Use an existing project (или Create a new project)
- Public directory: `build/web` (уже настроено в firebase.json)
- Single-page app: Yes
- Automatic builds: No

## После настройки

Проверьте:
```bash
firebase use
```

Должен показать текущий проект.

Затем деплой:
```bash
flutter build web --release
firebase deploy --only hosting
```

