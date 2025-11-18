#!/bin/bash

# Firebase Setup Script for OPAD Flutter Web App

set -e

echo "🔥 Firebase Setup для OPAD"
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI не установлен!"
    echo "Установите его командой: npm install -g firebase-tools"
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

echo "Выберите действие:"
echo "1) Использовать существующий проект"
echo "2) Создать новый проект"
read -p "Введите номер (1 или 2): " choice

case $choice in
    1)
        echo ""
        echo "Добавление существующего проекта..."
        firebase use --add
        ;;
    2)
        echo ""
        echo "Создайте проект на https://console.firebase.google.com/"
        echo "После создания выполните: firebase use --add"
        exit 0
        ;;
    *)
        echo "Неверный выбор"
        exit 1
        ;;
esac

echo ""
echo "✅ Проект настроен!"
echo ""
echo "Теперь выполните деплой:"
echo "  flutter build web --release"
echo "  firebase deploy --only hosting"

