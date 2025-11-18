# 🔥 Быстрая настройка Firebase

## Проблема
Ошибка: `Invalid project id: YOUR_PROJECT_ID`

## Решение

### Шаг 1: Посмотрите список ваших проектов

```bash
firebase projects:list
```

### Шаг 2: Выберите проект

**Вариант А - Интерактивный выбор:**
```bash
firebase use --add
```
- Выберите проект из списка
- Введите алиас: `default`
- Проект будет автоматически сохранен в `.firebaserc`

**Вариант Б - Прямое указание проекта:**
Если знаете ID проекта:
```bash
firebase use YOUR_ACTUAL_PROJECT_ID
```

### Шаг 3: Проверьте

```bash
firebase use
```

Должен показать текущий проект.

### Шаг 4: Деплой

```bash
flutter build web --release
firebase deploy --only hosting
```

## Если проекта нет

1. Создайте проект на https://console.firebase.google.com/
2. После создания выполните `firebase use --add`
3. Выберите созданный проект

