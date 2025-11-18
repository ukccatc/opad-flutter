# 🔥 Создание Firebase проекта через CLI

## Быстрый способ

### Вариант 1: Использовать скрипт (Рекомендуется)

```bash
cd "/Users/macbookpro/Git Actions/flutter-opad"
./scripts/create_firebase_project.sh
```

Скрипт попросит ввести название проекта и автоматически создаст и настроит его.

### Вариант 2: Вручную через CLI

1. **Создайте проект:**
   ```bash
   firebase projects:create opad-web --display-name "OPAD Web App"
   ```
   
   Замените `opad-web` на желаемое название проекта.

2. **Свяжите проект с локальной директорией:**
   ```bash
   firebase use opad-web --alias default
   ```

3. **Проверьте:**
   ```bash
   firebase use
   ```

4. **Деплой:**
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```

## Важные моменты

- **Project ID** будет сгенерирован автоматически на основе названия
- Название проекта должно быть уникальным в Firebase
- Если название занято, Firebase предложит альтернативу
- После создания проекта нужно включить Hosting в Firebase Console

## Включение Hosting после создания проекта

После создания проекта через CLI:

1. Откройте https://console.firebase.google.com/
2. Выберите созданный проект
3. Перейдите в "Hosting"
4. Нажмите "Get started"

Или инициализируйте hosting через CLI:

```bash
firebase init hosting
```

Выберите:
- ✅ Use an existing project
- Public directory: `build/web`
- Single-page app: Yes
- Automatic builds: No

## Проверка доступных команд

```bash
firebase projects:create --help
```

