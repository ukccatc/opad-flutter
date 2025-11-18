#!/bin/bash

# Create Firebase project via CLI

set -e

echo "🔥 Создание Firebase проекта через CLI"
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI не установлен!"
    echo "Установите: npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo "⚠️  Вы не авторизованы в Firebase"
    echo "Выполните: firebase login"
    exit 1
fi

# Get project name
read -p "Введите название проекта (например: opad-web): " PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
    echo "❌ Название проекта не может быть пустым"
    exit 1
fi

echo ""
echo "Создание проекта: $PROJECT_NAME"
echo "Это может занять несколько секунд..."
echo ""

# Create project
firebase projects:create "$PROJECT_NAME" --display-name "$PROJECT_NAME"

echo ""
echo "✅ Проект создан!"
echo ""

# Use the created project
echo "Связывание проекта с локальной директорией..."
firebase use "$PROJECT_NAME" --alias default

echo ""
echo "✅ Проект настроен!"
echo ""
echo "Текущий проект:"
firebase use
echo ""
echo "Теперь выполните деплой:"
echo "  flutter build web --release"
echo "  firebase deploy --only hosting"

