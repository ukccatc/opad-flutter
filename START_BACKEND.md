# Start Backend API Server

## Quick Start

The Flutter web app needs the backend API server running to work properly.

### Step 1: Open a New Terminal

Keep your Flutter app running in the current terminal.

### Step 2: Navigate to Backend Directory

```bash
cd flutter-opad/backend
```

### Step 3: Install Dependencies (First Time Only)

```bash
npm install
```

### Step 4: Create .env File (First Time Only)

```bash
cp .env.example .env
```

### Step 5: Start the Backend Server

```bash
npm start
```

You should see:
```
✅ Backend API server running on http://localhost:8000
📊 Database: s19.thehost.com.ua
```

## What This Does

- Connects to MySQL database at `s19.thehost.com.ua`
- Provides REST API endpoints for the Flutter web app
- Runs on `http://localhost:8000`

## Verify It's Working

In another terminal, test the health endpoint:

```bash
curl http://localhost:8000/api/health
```

Should return:
```json
{"status":"ok"}
```

## Now Your Flutter App Will Work

Once the backend is running:
1. The Flutter web app will connect successfully
2. You can login with your credentials
3. All features will work (billing profile, articles, password reset, etc.)

## Troubleshooting

### Backend won't start

**Error: `Cannot find module 'express'`**
```bash
npm install
```

**Error: `Port 8000 already in use`**
```bash
# Change PORT in backend/.env to 8001
# Or kill the process:
lsof -ti:8000 | xargs kill -9
```

**Error: `connect ECONNREFUSED` (MySQL connection failed)**
- Check MySQL is accessible: `mysql -h s19.thehost.com.ua -u opad2016 -p`
- Verify credentials in `backend/.env`

### Flutter app still can't connect

1. Make sure backend is running: `npm start`
2. Check backend is on `http://localhost:8000`
3. Open browser console (F12) and check for errors
4. Restart Flutter app: Press `r` in terminal

## Keep Both Running

You need **two terminals**:

**Terminal 1** (Flutter Web App):
```bash
cd flutter-opad
flutter run -d chrome
```

**Terminal 2** (Backend API Server):
```bash
cd flutter-opad/backend
npm start
```

Both must be running for the app to work!

## Next Steps

1. ✅ Start backend: `npm start` in `flutter-opad/backend`
2. ✅ Flutter app should connect automatically
3. ✅ Try logging in
4. ✅ Test other features

That's it! 🚀
