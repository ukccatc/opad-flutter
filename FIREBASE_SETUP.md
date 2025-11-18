# Firebase Setup Guide

## Проблема: Проект не найден

Если вы видите ошибку:
```
Error: Failed to get Firebase project opad-flutter
```

Это означает, что проект с таким ID не существует или у вас нет доступа к нему.

## Решение

### Вариант 1: Выбрать существующий проект

1. Посмотрите список ваших проектов:
   ```bash
   firebase projects:list
   ```

2. Выберите проект:
   ```bash
   firebase use PROJECT_ID
   ```

3. Или добавьте проект вручную:
   ```bash
   firebase use --add
   ```
   Затем выберите проект из списка и дайте ему алиас (например, "default")

### Вариант 2: Создать новый проект

1. Создайте проект в Firebase Console:
   - Перейдите на https://console.firebase.google.com/
   - Нажмите "Add project"
   - Введите название проекта (например, "opad-flutter")
   - Следуйте инструкциям

2. После создания проекта, свяжите его с локальной директорией:
   ```bash
   firebase use --add
   ```
   Выберите созданный проект

3. Обновите `.firebaserc`:
   ```json
   {
     "projects": {
       "default": "YOUR_PROJECT_ID"
     }
   }
   ```

### Вариант 3: Инициализировать заново

Если хотите начать с нуля:

```bash
cd "/Users/macbookpro/Git Actions/flutter-opad"
firebase init hosting
```

Выберите:
- ✅ Use an existing project (или Create a new project)
- Public directory: `build/web`
- Single-page app: Yes
- Automatic builds: No

## После настройки проекта

Выполните деплой:

```bash
flutter build web --release
firebase deploy --only hosting
```

## Проверка текущего проекта

Чтобы проверить, какой проект сейчас используется:

```bash
firebase use
```

