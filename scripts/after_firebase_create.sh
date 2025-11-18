#!/bin/bash

# Script to run after creating Firebase project
# This will link the new project to local directory

echo "🔗 Связывание Firebase проекта с локальной директорией..."
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

echo "📋 Ваши Firebase проекты:"
echo ""
firebase projects:list
echo ""

echo "Выберите проект для использования:"
firebase use --add

echo ""
echo "✅ Проект настроен!"
echo ""
echo "Проверка текущего проекта:"
firebase use
echo ""
echo "Теперь выполните деплой:"
echo "  flutter build web --release"
echo "  firebase deploy --only hosting"

