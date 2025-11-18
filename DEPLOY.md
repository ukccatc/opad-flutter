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

### 3. Firebase Hosting

```bash
npm install -g firebase-tools
firebase login
firebase init hosting
# Select build/web as public directory
firebase deploy --only hosting
```

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

