# thehost.ua Official Deployment Guide

Based on thehost.ua official documentation and support.

## Important: Check Your Hosting Type

thehost.ua offers different hosting types with different control panels:

1. **Shared Hosting** - Uses ISPManager (built-in Let's Encrypt)
2. **VPS/Dedicated Server** - Uses ISPManager or Certbot
3. **Cloud Hosting** - Uses VM-Cloud Control Panel

**Check which one you have** in your account settings.

## For Shared Hosting (ISPManager)

### Step 1: Upload Files via File Manager

1. Login to your hosting control panel
2. Go to **File Manager**
3. Navigate to `public_html`
4. Create folders:
   - `app` - for Flutter web app
   - `api` - for backend

### Step 2: Upload Flutter Web App

1. Build locally: `flutter build web --release`
2. Upload all files from `build/web/` to `public_html/app/`

### Step 3: Upload Backend

1. Prepare backend: `zip -r backend.zip flutter-opad/backend/ -x "node_modules/*"`
2. Upload `backend.zip` to `public_html/api/`
3. Extract it in File Manager

### Step 4: Install Let's Encrypt SSL (Built-in)

**For Shared Hosting - ISPManager has built-in Let's Encrypt:**

1. Go to **SSL Certificates** section
2. Click **Let's Encrypt** button
3. Select your domain
4. Click **OK**
5. Certificate appears in 20-30 seconds

### Step 5: Enable HTTPS Redirect

1. Go to **WWW Domains**
2. Select your domain
3. Click **Edit**
4. Check **SSL Only** option
5. Save

### Step 6: Configure Backend

Since shared hosting may not support Node.js directly, you have two options:

**Option A: Use a separate VPS for backend**
- Deploy backend on a VPS
- Update API URL in Flutter app

**Option B: Use PHP wrapper (if Node.js not available)**
- Contact thehost.ua support for Node.js support
- Ask about Node.js hosting options

---

## For VPS/Dedicated Server (ISPManager)

### Step 1: SSH Access

```bash
ssh username@yourdomain.ua
```

### Step 2: Create Directories

```bash
mkdir -p ~/public_html/app
mkdir -p ~/public_html/api
```

### Step 3: Upload Files

From your local machine:

```bash
# Upload Flutter app
scp -r flutter-opad/build/web/* username@yourdomain.ua:~/public_html/app/

# Upload backend
scp -r flutter-opad/backend/* username@yourdomain.ua:~/public_html/api/
```

### Step 4: Install Let's Encrypt (ISPManager)

**Via Control Panel:**

1. Go to **SSL Certificates**
2. Click **Let's Encrypt**
3. Select domain
4. Click **OK**

**Or via Certbot (Command Line):**

```bash
# Install Certbot
sudo apt update
sudo apt install -y certbot python3-certbot-nginx

# Issue certificate
sudo certbot --nginx

# Test renewal
sudo certbot renew --dry-run
```

### Step 5: Configure Backend

```bash
ssh username@yourdomain.ua
cd ~/public_html/api

# Install dependencies
npm install

# Create .env file
cat > .env << EOF
PORT=8000
DB_HOST=s19.thehost.com.ua
DB_USER=opad2016
DB_PASSWORD=opad2016
DB_NAME=opad
EOF

# Install PM2
npm install -g pm2

# Start backend
pm2 start server.js --name "opad-api"
pm2 save
pm2 startup
```

### Step 6: Enable HTTPS Redirect

**Via ISPManager:**
1. Go to **WWW Domains**
2. Select domain
3. Click **Edit**
4. Check **SSL Only**
5. Save

**Or via Nginx Config:**

Add to `/etc/nginx/nginx.conf`:

```nginx
if ($ssl_protocol = "") {
  rewrite ^ https://$server_name$request_uri? permanent;
}
```

---

## For Cloud Hosting (VM-Cloud Control Panel)

### Step 1: Access VM-Cloud Panel

1. Login to your account
2. Go to **VM-Cloud Control Panel**
3. Select your virtual machine

### Step 2: SSH into VM

```bash
ssh root@your.vm.ip
```

### Step 3: Install Web Server

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Nginx
sudo apt install -y nginx

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install PM2
sudo npm install -g pm2
```

### Step 4: Create Directories

```bash
mkdir -p /var/www/app
mkdir -p /var/www/api
```

### Step 5: Upload Files

```bash
# From local machine
scp -r flutter-opad/build/web/* root@your.vm.ip:/var/www/app/
scp -r flutter-opad/backend/* root@your.vm.ip:/var/www/api/
```

### Step 6: Configure Backend

```bash
ssh root@your.vm.ip
cd /var/www/api

npm install

cat > .env << EOF
PORT=8000
DB_HOST=s19.thehost.com.ua
DB_USER=opad2016
DB_PASSWORD=opad2016
DB_NAME=opad
EOF

pm2 start server.js --name "opad-api"
pm2 save
pm2 startup
```

### Step 7: Configure Nginx

Create `/etc/nginx/sites-available/default`:

```nginx
server {
    listen 80;
    server_name yourdomain.ua;

    # Flutter app
    location / {
        root /var/www/app;
        try_files $uri $uri/ /index.html;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:8000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Step 8: Install SSL with Certbot

```bash
sudo apt install -y certbot python3-certbot-nginx

sudo certbot --nginx

# Test renewal
sudo certbot renew --dry-run
```

---

## Update API URL Before Deployment

**Important:** Update this BEFORE building:

Edit `lib/services/api_service.dart`:

```dart
static const String _baseUrl = 'https://api.yourdomain.ua/api';
```

Then rebuild:

```bash
flutter build web --release
```

---

## Testing After Deployment

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

---

## Troubleshooting

### SSL Certificate Issues

**Error: Certificate not issued**

1. Make sure domain points to server (A record)
2. Make sure ports 80 and 443 are open
3. Delete these folders and retry:
   ```bash
   rm -rf ~/lets_encrypt
   rm -rf ~/.well-known/acme-challenge
   ```
4. Reissue certificate

### Backend Not Starting

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

### Database Connection Fails

```bash
# Test MySQL connection
mysql -h s19.thehost.com.ua -u opad2016 -p opad

# Check .env file
cat .env
```

### App Shows Blank Page

1. Check browser console (F12)
2. Check network tab for failed requests
3. Verify API URL is correct
4. Check backend is running

---

## thehost.ua Support

- **Support Email**: support@thehost.ua
- **Phone**: (044) 222-9-888
- **Help Wiki**: https://thehost.ua/en/wiki
- **Documentation**: https://thehost.ua/en/wiki/administration

---

## Deployment Checklist

- [ ] Determine your hosting type (Shared/VPS/Cloud)
- [ ] Update API URL in `lib/services/api_service.dart`
- [ ] Build Flutter web: `flutter build web --release`
- [ ] Upload backend to `public_html/api/`
- [ ] Upload frontend to `public_html/app/`
- [ ] Create `.env` file with credentials
- [ ] Install Node.js dependencies: `npm install`
- [ ] Start backend: `pm2 start server.js`
- [ ] Install Let's Encrypt SSL certificate
- [ ] Enable HTTPS redirect
- [ ] Test backend: `curl https://api.yourdomain.ua/api/health`
- [ ] Test frontend: Open `https://yourdomain.ua`
- [ ] Test login
- [ ] Test password reset
- [ ] Monitor logs: `pm2 logs opad-api`

---

## Next Steps

1. ✅ Identify your hosting type
2. ✅ Follow the appropriate section above
3. ✅ Test everything
4. ✅ Monitor logs
5. ✅ Contact thehost.ua support if issues

Good luck! 🚀
