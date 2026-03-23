# Deployment Guide - thehost.com.ua

## Overview

You need to deploy two things:
1. **Backend API Server** (Node.js) - Connects to MySQL
2. **Flutter Web App** - The frontend

## Architecture

```
thehost.com.ua
├── api.thehost.com.ua (Backend API - Node.js)
│   └── Connects to MySQL database
└── app.thehost.com.ua (Flutter Web App)
    └── Connects to Backend API
```

## Step 1: Deploy Backend API

### Option A: Using cPanel (Recommended for thehost.com.ua)

1. **SSH into your server**
   ```bash
   ssh username@thehost.com.ua
   ```

2. **Create backend directory**
   ```bash
   mkdir -p ~/public_html/api
   cd ~/public_html/api
   ```

3. **Upload backend files**
   ```bash
   # From your local machine
   scp -r flutter-opad/backend/* username@thehost.com.ua:~/public_html/api/
   ```

4. **Install dependencies**
   ```bash
   cd ~/public_html/api
   npm install
   ```

5. **Create .env file**
   ```bash
   cat > .env << EOF
   PORT=8000
   DB_HOST=s19.thehost.com.ua
   DB_USER=opad2016
   DB_PASSWORD=opad2016
   DB_NAME=opad
   EOF
   ```

6. **Start backend with PM2**
   ```bash
   npm install -g pm2
   pm2 start server.js --name "opad-api"
   pm2 save
   pm2 startup
   ```

### Option B: Using Node.js Hosting

If thehost.com.ua supports Node.js:

1. Create a subdomain: `api.thehost.com.ua`
2. Point it to your backend directory
3. Set environment variables in cPanel
4. Restart the application

## Step 2: Deploy Flutter Web App

### Build Flutter Web App

```bash
cd flutter-opad
flutter build web --release
```

This creates `build/web/` directory with all static files.

### Upload to thehost.com.ua

1. **Via cPanel File Manager**
   - Login to cPanel
   - Go to File Manager
   - Navigate to `public_html`
   - Upload contents of `build/web/`

2. **Via FTP**
   ```bash
   ftp username@thehost.com.ua
   cd public_html
   put -r build/web/*
   ```

3. **Via SCP**
   ```bash
   scp -r flutter-opad/build/web/* username@thehost.com.ua:~/public_html/
   ```

## Step 3: Update Configuration

### Update API URL in Flutter App

Before building, update the API URL:

**File: `lib/services/api_service.dart`**

```dart
static const String _baseUrl = 'https://api.thehost.com.ua/api';
```

Then rebuild:
```bash
flutter build web --release
```

## Step 4: Configure DNS

### Add Subdomains

In your domain registrar or cPanel:

1. **api.thehost.com.ua** → Points to backend server
2. **app.thehost.com.ua** → Points to Flutter web app (optional)

Or use:
- **thehost.com.ua** → Flutter web app
- **api.thehost.com.ua** → Backend API

## Step 5: Enable HTTPS/SSL

### In cPanel

1. Go to AutoSSL or Let's Encrypt
2. Install SSL certificate for:
   - `thehost.com.ua`
   - `api.thehost.com.ua`
3. Force HTTPS redirect

### Update API URL to HTTPS

```dart
static const String _baseUrl = 'https://api.thehost.com.ua/api';
```

## Step 6: Configure CORS

### Backend CORS Settings

The backend already has CORS enabled, but verify in `backend/server.js`:

```javascript
app.use(cors());
```

If you need to restrict to specific domains:

```javascript
app.use(cors({
  origin: ['https://thehost.com.ua', 'https://app.thehost.com.ua'],
  credentials: true
}));
```

## Step 7: Test Deployment

### Test Backend API

```bash
curl https://api.thehost.com.ua/api/health
```

Should return:
```json
{"status":"ok"}
```

### Test Login

1. Open `https://thehost.com.ua` in browser
2. Try to login
3. Check browser console (F12) for logs
4. Check backend logs: `pm2 logs opad-api`

## Troubleshooting

### Backend not responding

```bash
# Check if running
pm2 list

# View logs
pm2 logs opad-api

# Restart
pm2 restart opad-api

# Check port
netstat -tlnp | grep 8000
```

### CORS errors

Add to backend `server.js`:
```javascript
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true
}));
```

### Database connection fails

Check `.env` file:
```bash
cat .env
```

Verify credentials:
```bash
mysql -h s19.thehost.com.ua -u opad2016 -p opad
```

### Flutter app shows blank page

1. Check browser console (F12)
2. Check network tab for failed requests
3. Verify API URL is correct
4. Check backend is running

## File Structure on Server

```
thehost.com.ua/
├── public_html/                    # Flutter web app
│   ├── index.html
│   ├── main.dart.js
│   ├── assets/
│   └── ...
└── api/                            # Backend API
    ├── server.js
    ├── package.json
    ├── .env
    ├── node_modules/
    └── ...
```

## Maintenance

### Update Backend

```bash
cd ~/public_html/api
git pull origin main  # or upload new files
npm install
pm2 restart opad-api
```

### Update Flutter App

```bash
cd flutter-opad
git pull origin main
flutter build web --release
# Upload build/web/* to public_html
```

### Monitor Logs

```bash
# Backend logs
pm2 logs opad-api

# Real-time monitoring
pm2 monit
```

## Security Checklist

- ✅ HTTPS/SSL enabled
- ✅ Database credentials in `.env` (not in code)
- ✅ CORS configured properly
- ✅ Input validation on backend
- ✅ Rate limiting enabled
- ✅ Firewall rules configured
- ✅ Regular backups enabled
- ✅ Monitor error logs

## Performance Tips

1. **Enable caching**
   ```javascript
   app.use(express.static('public', { maxAge: '1d' }));
   ```

2. **Use CDN for static files**
   - Upload `build/web/` to CDN
   - Update index.html to use CDN URLs

3. **Database optimization**
   - Add indexes to frequently queried columns
   - Use connection pooling (already configured)

4. **Monitor performance**
   ```bash
   pm2 web  # Opens web dashboard on port 9615
   ```

## Deployment Checklist

- [ ] Backend uploaded to `~/public_html/api/`
- [ ] `.env` file created with correct credentials
- [ ] `npm install` completed
- [ ] Backend running with PM2
- [ ] Flutter app built: `flutter build web --release`
- [ ] `build/web/` uploaded to `public_html/`
- [ ] API URL updated to `https://api.thehost.com.ua/api`
- [ ] SSL certificates installed
- [ ] CORS configured
- [ ] Tested login flow
- [ ] Tested password reset
- [ ] Monitored logs for errors
- [ ] Set up automated backups

## Support

For thehost.com.ua specific issues:
- Contact their support team
- Check their documentation
- Use their cPanel help

For app issues:
- Check browser console (F12)
- Check backend logs: `pm2 logs opad-api`
- Review this guide's troubleshooting section

## Next Steps

1. ✅ Build Flutter web: `flutter build web --release`
2. ✅ Upload backend to server
3. ✅ Upload Flutter app to server
4. ✅ Update API URL
5. ✅ Test everything
6. ✅ Monitor logs
7. ✅ Set up backups

Good luck! 🚀
