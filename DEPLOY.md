# 🚀 Quick Deployment Guide

## Build for Production

```bash
cd "/Users/macbookpro/Git Actions/flutter-opad"
flutter build web --release
```

The built files will be in `build/web/` directory.

## Deploy Options

### 1. GitHub Pages (Recommended)

After building, deploy using GitHub Actions workflow (already configured in `.github/workflows/deploy.yml`):

1. Push to `main` branch - deployment will happen automatically
2. Or manually trigger: GitHub → Actions → Deploy Flutter Web → Run workflow

### 2. Manual Deploy to GitHub Pages

```bash
cd build/web
git init
git add .
git commit -m "Deploy OPAD web app"
git branch -M main
git remote add origin YOUR_REPO_URL
git push -f origin main:gh-pages
```

### 3. Firebase Hosting (Recommended)

**Быстрый деплой:**
```bash
cd "/Users/macbookpro/Git Actions/flutter-opad"
./scripts/deploy_firebase.sh
```

**Или вручную:**
```bash
# 1. Установите Firebase CLI (если еще не установлен)
npm install -g firebase-tools

# 2. Войдите в Firebase
firebase login

# 3. Инициализируйте проект (если первый раз)
firebase init hosting
# Выберите существующий проект или создайте новый
# Public directory: build/web
# Configure as single-page app: Yes
# Set up automatic builds: No

# 4. Соберите приложение
flutter build web --release

# 5. Задеплойте
firebase deploy --only hosting
```

**Конфигурация уже настроена:**
- `firebase.json` - конфигурация хостинга
- `.firebaserc` - проект по умолчанию (измените на свой)

### 4. Netlify

```bash
npm install -g netlify-cli
netlify login
netlify deploy --prod --dir=build/web
```

### 5. Traditional Server

Copy `build/web/*` to your web server's public directory.

## Important Notes

- All uploaded files are in `build/web/assets/uploads/`
- Logo SVG is in `build/web/assets/logo.svg`
- Make sure web server supports SPA routing (redirect all routes to index.html)

## Testing Locally

Before deploying, test locally:

```bash
cd build/web
python3 -m http.server 8000
# Or
npx serve .
```

Then open http://localhost:8000

