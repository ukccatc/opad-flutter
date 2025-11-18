#!/bin/bash

# Firebase Deployment Script for OPAD Flutter Web App

set -e

echo "🚀 Starting Firebase deployment process..."

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

# Build Flutter web app
echo "📦 Building Flutter web app..."
flutter build web --release

# Check if build was successful
if [ ! -d "build/web" ]; then
    echo "❌ Ошибка сборки! Директория build/web не найдена"
    exit 1
fi

echo "✅ Сборка завершена успешно"

# Deploy to Firebase
echo "🌐 Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo "✅ Деплой завершен успешно!"
echo "📱 Ваше приложение доступно по адресу, указанному в Firebase консоли"

