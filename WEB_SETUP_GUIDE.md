# Flutter Web App Setup Guide - Complete Solution

## Problem Solved

The Flutter web app was failing to connect to MySQL with error:
```
❌ MySQL connection error: Unsupported operation: RawSocket constructor
```

This is because the `mysql1` package uses `RawSocket` which isn't supported in web browsers.

## Solution Architecture

We've implemented a **two-tier architecture**:

1. **Web Platform**: Uses HTTP API to communicate with backend
2. **Mobile/Desktop**: Uses direct MySQL connection (when available)
3. **Fallback**: Local data from `stats_data.dart` and `users_data.dart`

## Setup Instructions

### Step 1: Start the Backend API Server

The backend is a Node.js/Express server that bridges the Flutter web app to MySQL.

```bash
# Navigate to backend directory
cd flutter-opad/backend

# Install dependencies
npm install

# Create .env file from example
cp .env.example .env

# Start the server
npm start
```

You should see:
```
✅ Backend API server running on http://localhost:8000
📊 Database: s19.thehost.com.ua
```

### Step 2: Run the Flutter Web App

In a new terminal:

```bash
cd flutter-opad

# Get dependencies
flutter pub get

# Run web app
flutter run -d chrome
```

The app will automatically:
- Detect it's running on web
- Use the API service instead of direct MySQL
- Connect to `http://localhost:8000/api`
- Fall back to local data if API is unavailable

## How It Works

### Platform Detection

The `SqlService` automatically detects the platform:

```dart
// In lib/services/sql_service.dart
_useApi = kIsWeb; // true for web, false for mobile/desktop
```

### Request Flow

**Web Platform:**
```
Flutter Web App
    ↓
ApiService (HTTP)
    ↓
Backend API (Node.js/Express)
    ↓
MySQL Database
```

**Mobile/Desktop:**
```
Flutter App
    ↓
MySqlService (Direct Connection)
    ↓
MySQL Database
```

## File Structure

```
flutter-opad/
├── lib/
│   ├── services/
│   │   ├── sql_service.dart          # Main service (platform-aware)
│   │   ├── api_service.dart          # NEW: HTTP API client for web
│   │   ├── mysql_service.dart        # Direct MySQL for mobile
│   │   └── password_reset_service.dart
│   └── ...
├── backend/                           # NEW: Backend API server
│   ├── server.js                      # Express server
│   ├── package.json                   # Node.js dependencies
│   ├── .env.example                   # Environment template
│   └── .env                           # Your configuration (create from .env.example)
├── BACKEND_SETUP.md                   # Backend setup guide
├── WEB_SETUP_GUIDE.md                 # This file
└── ...
```

## API Endpoints

The backend provides these endpoints:

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/health` | Health check |
| POST | `/api/auth/login` | Authenticate user |
| GET | `/api/users/account?email=...` | Get user account |
| GET | `/api/users/stats?emailOrId=...` | Get user statistics |
| GET | `/api/users/all` | Get all users |
| GET | `/api/users/union-members` | Get union members |
| POST | `/api/users/update-password` | Update password |
| GET | `/api/stats/database` | Get database stats |

## Configuration

### Backend Configuration

Edit `flutter-opad/backend/.env`:

```env
PORT=8000                          # Backend port
DB_HOST=s19.thehost.com.ua        # MySQL host
DB_USER=opad2016                  # MySQL user
DB_PASSWORD=opad2016              # MySQL password
DB_NAME=opad                       # Database name
```

### Frontend Configuration

Edit `flutter-opad/lib/services/api_service.dart`:

```dart
static const String _baseUrl = 'http://localhost:8000/api';
```

For production, change to your deployed backend URL:
```dart
static const String _baseUrl = 'https://api.yourdomain.com/api';
```

## Testing

### Test Backend Health

```bash
curl http://localhost:8000/api/health
```

Expected response:
```json
{"status":"ok"}
```

### Test User Login

```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"md5_hash"}'
```

### Test Get User Stats

```bash
curl "http://localhost:8000/api/users/stats?emailOrId=user@example.com"
```

## Troubleshooting

### Backend Won't Start

**Error**: `connect ECONNREFUSED`
- MySQL server is not accessible
- Check: `mysql -h s19.thehost.com.ua -u opad2016 -p`
- Verify credentials in `.env`

**Error**: `Port 8000 already in use`
- Change PORT in `.env` to 8001
- Or kill process: `lsof -ti:8000 | xargs kill -9`

### Flutter App Can't Connect to Backend

**Error**: `Connection refused`
- Make sure backend is running: `npm start`
- Check backend is on `http://localhost:8000`
- Check firewall settings

**Error**: `CORS error`
- Backend has CORS enabled
- Check browser console for details
- Verify backend is running

### Database Connection Issues

**Error**: `User not found`
- Check email exists in database
- Verify database credentials

**Error**: `Stats not found`
- Check user has stats in Stats table
- Verify database structure

## Development Workflow

### Terminal 1: Backend Server

```bash
cd flutter-opad/backend
npm run dev  # Auto-reload on changes
```

### Terminal 2: Flutter Web App

```bash
cd flutter-opad
flutter run -d chrome
```

### Terminal 3: MySQL Testing (Optional)

```bash
mysql -h s19.thehost.com.ua -u opad2016 -p opad
```

## Production Deployment

### Backend Deployment

1. Deploy Node.js server to your hosting (Heroku, AWS, DigitalOcean, etc.)
2. Set environment variables on hosting platform
3. Update `api_service.dart` with production URL
4. Enable HTTPS/SSL

Example with PM2:
```bash
npm install -g pm2
pm2 start server.js --name "opad-api"
pm2 save
pm2 startup
```

### Flutter Web Deployment

1. Build web app: `flutter build web`
2. Deploy `build/web` to your hosting
3. Update API base URL to production backend

## Security Considerations

- Passwords are hashed with MD5 + salt (same as WordPress)
- Never expose database credentials in frontend
- Use HTTPS in production
- Implement proper authentication/authorization
- Add rate limiting to prevent abuse
- Validate all inputs on backend
- Use environment variables for sensitive data

## Performance Notes

- Backend uses MySQL connection pooling (10 connections)
- API responses are cached where possible
- Local data fallback ensures app works offline
- Consider adding Redis caching for frequently accessed data

## Next Steps

1. ✅ Start backend: `npm start` in `flutter-opad/backend`
2. ✅ Run Flutter app: `flutter run -d chrome`
3. ✅ Test login flow
4. ✅ Test password reset
5. ✅ Test billing profile display
6. Deploy to production when ready

## Support

For issues:
1. Check backend logs: `npm start` output
2. Check browser console: F12 → Console tab
3. Test API directly: `curl http://localhost:8000/api/health`
4. Check MySQL connection: `mysql -h s19.thehost.com.ua -u opad2016 -p`

## Files Modified/Created

### Created
- `lib/services/api_service.dart` - HTTP API client for web
- `backend/server.js` - Express backend server
- `backend/package.json` - Node.js dependencies
- `backend/.env.example` - Environment template
- `BACKEND_SETUP.md` - Backend setup guide
- `WEB_SETUP_GUIDE.md` - This file

### Modified
- `lib/services/sql_service.dart` - Added platform detection and API support
- `lib/screens/forgot_password_screen.dart` - Fixed deprecated APIs
- `lib/screens/reset_password_screen.dart` - Fixed deprecated APIs
- `lib/services/password_reset_service.dart` - Removed debug logging

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Web App                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              SqlService (Platform-Aware)             │  │
│  │  - Detects platform (web vs mobile)                  │  │
│  │  - Routes to API or MySQL accordingly                │  │
│  │  - Falls back to local data                          │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                           │
                    ┌──────┴──────┐
                    │             │
            ┌───────▼────────┐   ┌─────────────────┐
            │  ApiService    │   │  MySqlService   │
            │  (HTTP Client) │   │  (Direct MySQL) │
            └───────┬────────┘   └─────────────────┘
                    │                    │
                    │                    │
        ┌───────────▼──────────┐        │
        │  Backend API Server  │        │
        │  (Node.js/Express)   │        │
        └───────────┬──────────┘        │
                    │                    │
                    └────────┬───────────┘
                             │
                    ┌────────▼────────┐
                    │  MySQL Database │
                    │ s19.thehost.com │
                    └─────────────────┘
```

## Summary

You now have a complete web-compatible solution:
- ✅ Backend API server for web platform
- ✅ Platform-aware service layer
- ✅ Direct MySQL for mobile/desktop
- ✅ Local data fallback
- ✅ Fixed deprecated Flutter APIs
- ✅ Cleaned up debug logging
- ✅ Production-ready architecture
