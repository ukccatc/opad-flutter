# thehost.ua Deployment Setup

## Overview

thehost.ua is a Ukrainian hosting provider. Here's how to deploy your Flutter app and backend there.

## Step 1: Access Your thehost.ua Account

1. Go to https://thehost.ua/en
2. Login to your control panel
3. Navigate to your hosting account

## Step 2: Prepare Your Files

### Build Flutter Web App

```bash
cd flutter-opad

# Update API URL first
# Edit: lib/services/api_service.dart
# Change: static const String _baseUrl = 'https://api.yourdomain.ua/api';

flutter build web --release
```

This creates `build/web/` with all static files.

### Prepare Backend

```bash
cd flutter-opad/backend

# Create deployment package
zip -r opad-backend.zip . -x "node_modules/*" ".git/*"
```

## Step 3: Upload via cPanel File Manager

### Option A: Using cPanel File Manager (Easiest)

1. **Login to cPanel**
   - Go to your hosting control panel
   - Find "File Manager"

2. **Create directories**
   - Navigate to `public_html`
   - Create folder: `app` (for Flutter web)
   - Create folder: `api` (for backend)

3. **Upload Flutter Web App**
   - Go to `public_html/app`
   - Upload all files from `build/web/`
   - Or upload `build/web.zip` and extract

4. **Upload Backend**
   - Go to `public_html/api`
   - Upload `opad-backend.zip`
   - Extract it
   - Delete `opad-backend.zip`

### Option B: Using FTP

1. **Get FTP credentials from cPanel**
   - FTP Account section
   - Note: hostname, username, password

2. **Connect via FTP**
   ```bash
   ftp ftp.yourdomain.ua
   # Enter username and password
   ```

3. **Upload files**
   ```
   cd public_html
   mkdir app
   mkdir api
   cd app
   put -r build/web/*
   cd ../api
   put opad-backend.zip
   ```

### Option C: Using SSH/Terminal

1. **SSH into server**
   ```bash
   ssh username@yourdomain.ua
   ```

2. **Create directories**
   ```bash
   mkdir -p ~/public_html/app
   mkdir -p ~/public_html/api
   ```

3. **Upload from local machine**
   ```bash
   # From your local machine
   scp -r flutter-opad/build/web/* username@yourdomain.ua:~/public_html/app/
   scp -r flutter-opad/backend/* username@yourdomain.ua:~/public_html/api/
   ```

## Step 4: Configure Backend

### Via SSH Terminal

```bash
# SSH into server
ssh username@yourdomain.ua

# Go to backend directory
cd ~/public_html/api

# Install Node.js dependencies
npm install

# Create .env file
cat > .env << EOF
PORT=8000
DB_HOST=s19.thehost.com.ua
DB_USER=opad2016
DB_PASSWORD=opad2016
DB_NAME=opad
EOF

# Install PM2 globally
npm install -g pm2

# Start backend
pm2 start server.js --name "opad-api"

# Save PM2 configuration
pm2 save
pm2 startup
```

## Step 5: Configure Subdomains

### In thehost.ua Control Panel

1. **Go to Domains section**
2. **Add subdomains:**
   - `app.yourdomain.ua` → Points to `public_html/app`
   - `api.yourdomain.ua` → Points to `public_html/api`

Or use:
   - `yourdomain.ua` → Points to `public_html/app`
   - `api.yourdomain.ua` → Points to `public_html/api`

### DNS Configuration

If using external DNS:
```
app.yourdomain.ua  A  your.server.ip
api.yourdomain.ua  A  your.server.ip
```

## Step 6: Enable SSL/HTTPS

### In thehost.ua Control Panel

1. **Go to SSL Certificates**
2. **Install Let's Encrypt (Free)**
   - Select domains:
     - yourdomain.ua
     - app.yourdomain.ua
     - api.yourdomain.ua
   - Click "Install"

3. **Force HTTPS**
   - Go to Redirects
   - Add redirect: `http://yourdomain.ua` → `https://yourdomain.ua`

## Step 7: Update Flutter App Configuration

### Update API URL

Edit `lib/services/api_service.dart`:

```dart
static const String _baseUrl = 'https://api.yourdomain.ua/api';
```

### Rebuild

```bash
flutter build web --release
```

### Re-upload

Upload new `build/web/` files to `public_html/app/`

## Step 8: Test Deployment

### Test Backend API

```bash
curl https://api.yourdomain.ua/api/health
```

Should return:
```json
{"status":"ok"}
```

### Test Frontend

1. Open `https://yourdomain.ua` in browser
2. Check browser console (F12) for errors
3. Try login
4. Try password reset

### Check Backend Logs

```bash
ssh username@yourdomain.ua
pm2 logs opad-api
```

## Directory Structure on Server

```
public_html/
├── app/                          # Flutter Web App
│   ├── index.html
│   ├── main.dart.js
│   ├── assets/
│   ├── canvaskit/
│   └── ...
│
└── api/                          # Backend API
    ├── server.js
    ├── package.json
    ├── .env
    ├── node_modules/
    └── ...
```

## Common Issues & Solutions

### Issue: Backend not starting

```bash
# Check if Node.js is installed
node --version

# Check PM2 status
pm2 list

# View logs
pm2 logs opad-api

# Restart
pm2 restart opad-api
```

### Issue: CORS errors in browser

Add to `backend/server.js`:
```javascript
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true
}));
```

### Issue: Database connection fails

```bash
# Test MySQL connection
mysql -h s19.thehost.com.ua -u opad2016 -p opad

# Check .env file
cat .env
```

### Issue: App shows blank page

1. Check browser console (F12)
2. Check network tab for failed requests
3. Verify API URL is correct
4. Check backend is running: `pm2 list`

### Issue: 404 errors on page refresh

Add `.htaccess` to `public_html/app/`:

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /app/
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /app/index.html [L]
</IfModule>
```

## Maintenance Commands

### Monitor Backend

```bash
ssh username@yourdomain.ua

# View logs
pm2 logs opad-api

# Real-time monitoring
pm2 monit

# List processes
pm2 list

# Restart backend
pm2 restart opad-api

# Stop backend
pm2 stop opad-api

# Start backend
pm2 start server.js --name "opad-api"
```

### Update Backend

```bash
cd ~/public_html/api

# Stop backend
pm2 stop opad-api

# Update files
# (upload new files via FTP/SCP)

# Install dependencies
npm install

# Start backend
pm2 start server.js --name "opad-api"
```

### Update Frontend

```bash
# Build locally
flutter build web --release

# Upload build/web/* to public_html/app/
# (via FTP/SCP/cPanel)
```

## Security Checklist

- ✅ HTTPS/SSL enabled
- ✅ Database credentials in `.env` (not in code)
- ✅ `.env` file not committed to git
- ✅ CORS configured properly
- ✅ Input validation on backend
- ✅ Regular backups enabled
- ✅ Monitor error logs
- ✅ Keep dependencies updated

## Backup Strategy

### Automated Backups

In thehost.ua cPanel:
1. Go to Backup section
2. Enable daily/weekly backups
3. Set retention policy

### Manual Backup

```bash
# Backup database
mysqldump -h s19.thehost.com.ua -u opad2016 -p opad > opad_backup.sql

# Backup files
tar -czf opad_files_backup.tar.gz ~/public_html/app ~/public_html/api
```

## Performance Tips

1. **Enable caching**
   - Add `.htaccess` with cache headers
   - Use CDN for static files

2. **Optimize database**
   - Add indexes to frequently queried columns
   - Monitor query performance

3. **Monitor performance**
   ```bash
   pm2 web  # Opens dashboard on port 9615
   ```

## Support

- **thehost.ua Support**: https://thehost.ua/en/support
- **Your Team**: [contact info]
- **Emergency**: [emergency contact]

## Deployment Checklist

- [ ] Flutter app built: `flutter build web --release`
- [ ] API URL updated in `lib/services/api_service.dart`
- [ ] Backend uploaded to `public_html/api/`
- [ ] Frontend uploaded to `public_html/app/`
- [ ] `.env` file created with credentials
- [ ] `npm install` completed
- [ ] Backend running: `pm2 start server.js`
- [ ] Subdomains configured
- [ ] SSL certificates installed
- [ ] HTTPS redirect enabled
- [ ] Backend API tested: `curl https://api.yourdomain.ua/api/health`
- [ ] Frontend loads: `https://yourdomain.ua`
- [ ] Login tested
- [ ] Password reset tested
- [ ] Logs monitored
- [ ] Backups enabled

## Next Steps

1. ✅ Build Flutter web app
2. ✅ Upload backend to `public_html/api/`
3. ✅ Upload frontend to `public_html/app/`
4. ✅ Configure subdomains
5. ✅ Install SSL certificates
6. ✅ Test everything
7. ✅ Monitor logs
8. ✅ Set up backups

Good luck! 🚀
