# Deployment Guide for OPAD Flutter Web Application

## 📦 Building for Production

### Step 1: Build the Web Application

```bash
cd "/Users/macbookpro/Git Actions/flutter-opad"
flutter build web --release
```

This will create optimized production files in `build/web/` directory.

### Step 2: Verify Build Output

After building, check that the following files exist in `build/web/`:
- `index.html`
- `main.dart.js`
- `assets/` directory with all uploaded files
- `icons/` directory
- `manifest.json`

## 🚀 Deployment Options

### Option 1: GitHub Pages

1. **Install GitHub Pages plugin** (if using gh-pages):
   ```bash
   npm install -g gh-pages
   ```

2. **Deploy to GitHub Pages**:
   ```bash
   cd build/web
   git init
   git add .
   git commit -m "Deploy OPAD Flutter Web App"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
   git push -f origin main:gh-pages
   ```

   Or use gh-pages:
   ```bash
   gh-pages -d build/web
   ```

3. **Enable GitHub Pages** in repository settings:
   - Go to Settings → Pages
   - Select source branch: `gh-pages`
   - Save

### Option 2: Firebase Hosting

1. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

2. **Initialize Firebase**:
   ```bash
   firebase init hosting
   ```
   - Select existing project or create new
   - Public directory: `build/web`
   - Configure as single-page app: Yes
   - Set up automatic builds: No

3. **Deploy**:
   ```bash
   firebase deploy --only hosting
   ```

### Option 3: Netlify

1. **Install Netlify CLI**:
   ```bash
   npm install -g netlify-cli
   netlify login
   ```

2. **Deploy**:
   ```bash
   netlify deploy --prod --dir=build/web
   ```

### Option 4: Vercel

1. **Install Vercel CLI**:
   ```bash
   npm install -g vercel
   ```

2. **Deploy**:
   ```bash
   cd build/web
   vercel --prod
   ```

### Option 5: Traditional Web Server (Apache/Nginx)

1. **Copy files to server**:
   ```bash
   scp -r build/web/* user@your-server.com:/var/www/html/
   ```

2. **Configure web server**:

   **Apache (.htaccess)**:
   ```apache
   RewriteEngine On
   RewriteBase /
   RewriteRule ^index\.html$ - [L]
   RewriteCond %{REQUEST_FILENAME} !-f
   RewriteCond %{REQUEST_FILENAME} !-d
   RewriteRule . /index.html [L]
   ```

   **Nginx**:
   ```nginx
   location / {
     try_files $uri $uri/ /index.html;
   }
   ```

## 🔧 Configuration

### Base URL Configuration

If deploying to a subdirectory (e.g., `/opad/`), update `web/index.html`:

```html
<base href="/opad/">
```

Or build with base href:
```bash
flutter build web --release --base-href="/opad/"
```

### Environment Variables

If you need environment-specific configuration, create a `.env` file and use `flutter_dotenv` package.

## 📝 Post-Deployment Checklist

- [ ] Verify all assets load correctly (logo, icons, uploaded files)
- [ ] Test file downloads (PDF, DOC files)
- [ ] Test authentication flow
- [ ] Test navigation between pages
- [ ] Verify responsive design on mobile devices
- [ ] Check browser console for errors
- [ ] Test on different browsers (Chrome, Firefox, Safari, Edge)
- [ ] Verify HTTPS is enabled (required for PWA features)

## 🐛 Troubleshooting

### Files not loading

- Check that `web/assets/uploads/` directory is included in build
- Verify file paths in `uploaded_files_data.dart` match actual file locations
- Check browser console for 404 errors

### Routing issues

- Ensure web server is configured for single-page app routing
- Check that `base href` is set correctly in `index.html`

### Performance issues

- Enable gzip compression on web server
- Consider using CDN for static assets
- Check bundle size: `flutter build web --release --analyze-size`

## 📊 Build Size Optimization

To reduce build size:

```bash
flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=false
```

Or use HTML renderer (smaller but less compatible):
```bash
flutter build web --release --web-renderer html
```

## 🔄 Continuous Deployment

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Web

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
      - run: flutter pub get
      - run: flutter build web --release
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

## 📞 Support

For deployment issues, check:
- Flutter Web documentation: https://docs.flutter.dev/deployment/web
- Firebase Hosting: https://firebase.google.com/docs/hosting
- GitHub Pages: https://pages.github.com/

