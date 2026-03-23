# Quick Start - Flutter OPAD Web App

## 5-Minute Setup

### Terminal 1: Start Backend API

```bash
cd flutter-opad/backend
npm install
cp .env.example .env
npm start
```

Wait for:
```
✅ Backend API server running on http://localhost:8000
```

### Terminal 2: Run Flutter Web App

```bash
cd flutter-opad
flutter run -d chrome
```

The app will open in Chrome and automatically connect to the backend.

## What Just Happened?

1. **Backend Server** (Node.js/Express)
   - Connects to MySQL database
   - Provides REST API endpoints
   - Runs on `http://localhost:8000`

2. **Flutter Web App**
   - Detects it's running on web
   - Uses API service instead of direct MySQL
   - Connects to backend API
   - Falls back to local data if needed

## Test It

### Login
- Email: Any email from the database
- Password: The actual password (will be hashed with MD5)

### Check Backend Health
```bash
curl http://localhost:8000/api/health
```

Should return:
```json
{"status":"ok"}
```

## Troubleshooting

### Backend won't start
```bash
# Check MySQL connection
mysql -h s19.thehost.com.ua -u opad2016 -p

# Check port 8000 is free
lsof -ti:8000 | xargs kill -9

# Try different port
# Edit backend/.env and change PORT=8001
```

### Flutter app can't connect
```bash
# Make sure backend is running
curl http://localhost:8000/api/health

# Check browser console (F12)
# Look for CORS or connection errors
```

### Database connection issues
```bash
# Verify credentials in backend/.env
cat backend/.env

# Test MySQL directly
mysql -h s19.thehost.com.ua -u opad2016 -p opad
```

## File Structure

```
flutter-opad/
├── backend/              ← Start here: npm start
│   ├── server.js
│   ├── package.json
│   └── .env
├── lib/
│   ├── services/
│   │   ├── api_service.dart      ← NEW: Web API client
│   │   ├── sql_service.dart      ← UPDATED: Platform-aware
│   │   └── mysql_service.dart    ← Mobile/desktop
│   └── ...
└── ...
```

## Key Files

| File | Purpose |
|------|---------|
| `backend/server.js` | Backend API server |
| `lib/services/api_service.dart` | Web API client |
| `lib/services/sql_service.dart` | Platform-aware service |
| `BACKEND_SETUP.md` | Detailed backend guide |
| `WEB_SETUP_GUIDE.md` | Complete setup guide |

## Common Tasks

### Change Backend Port
Edit `backend/.env`:
```env
PORT=8001
```

### Change Database Credentials
Edit `backend/.env`:
```env
DB_HOST=your-host
DB_USER=your-user
DB_PASSWORD=your-password
DB_NAME=your-database
```

### Change API URL (for production)
Edit `lib/services/api_service.dart`:
```dart
static const String _baseUrl = 'https://api.yourdomain.com/api';
```

### Run Backend in Development Mode
```bash
cd backend
npm run dev  # Auto-reload on changes
```

## Architecture

```
Web Browser
    ↓
Flutter Web App
    ↓
ApiService (HTTP)
    ↓
Backend API (Node.js)
    ↓
MySQL Database
```

## Next Steps

1. ✅ Backend running? `npm start`
2. ✅ Flutter app running? `flutter run -d chrome`
3. ✅ Can you login?
4. ✅ Can you see billing profile?
5. ✅ Can you reset password?

If all working → Ready for production!

## Production Checklist

- [ ] Backend deployed to production server
- [ ] API URL updated in `api_service.dart`
- [ ] HTTPS/SSL enabled
- [ ] Environment variables set on server
- [ ] Database credentials secured
- [ ] Flutter app built: `flutter build web`
- [ ] Web app deployed to hosting
- [ ] Tested login flow
- [ ] Tested password reset
- [ ] Tested billing profile

## Support

See detailed guides:
- `BACKEND_SETUP.md` - Backend configuration
- `WEB_SETUP_GUIDE.md` - Complete setup
- `CHANGES_SUMMARY.md` - What changed

## Quick Commands

```bash
# Start backend
cd backend && npm start

# Run Flutter web
flutter run -d chrome

# Build Flutter web
flutter build web

# Test backend health
curl http://localhost:8000/api/health

# Test MySQL
mysql -h s19.thehost.com.ua -u opad2016 -p opad

# Kill process on port 8000
lsof -ti:8000 | xargs kill -9

# View backend logs
npm start

# View Flutter logs
flutter run -d chrome
```

## That's It!

You now have a fully functional Flutter web app with:
- ✅ Web-compatible database access
- ✅ Mobile/desktop support
- ✅ Local data fallback
- ✅ Production-ready setup

Happy coding! 🚀
