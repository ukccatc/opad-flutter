# OPAD Backend API Setup Guide

## Overview

The Flutter web app requires a backend API server to access the MySQL database. This is because Flutter web cannot use the `mysql1` package directly (it uses `RawSocket` which isn't supported in web browsers).

The backend is a simple Node.js/Express server that provides REST API endpoints for database operations.

## Prerequisites

- Node.js 14+ and npm
- MySQL database access (s19.thehost.com.ua)
- Database credentials: `opad2016` / `opad2016`

## Installation

### 1. Install Node.js

If you don't have Node.js installed:
- **macOS**: `brew install node`
- **Windows**: Download from https://nodejs.org/
- **Linux**: `sudo apt-get install nodejs npm`

### 2. Setup Backend

```bash
cd flutter-opad/backend
npm install
```

### 3. Configure Environment

Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

Edit `.env` with your database credentials:

```env
PORT=8000
DB_HOST=s19.thehost.com.ua
DB_USER=opad2016
DB_PASSWORD=opad2016
DB_NAME=opad
```

### 4. Start Backend Server

```bash
npm start
```

You should see:
```
✅ Backend API server running on http://localhost:8000
📊 Database: s19.thehost.com.ua
```

## API Endpoints

### Health Check
- **GET** `/api/health`
- Returns: `{ "status": "ok" }`

### Authentication
- **POST** `/api/auth/login`
- Body: `{ "email": "user@example.com", "password": "md5_hash" }`
- Returns: `{ "success": true/false }`

### User Account
- **GET** `/api/users/account?email=user@example.com`
- Returns: User account details

### User Statistics
- **GET** `/api/users/stats?emailOrId=user@example.com`
- Returns: User statistics from Stats table

### All Users
- **GET** `/api/users/all`
- Returns: Array of all users

### Union Members
- **GET** `/api/users/union-members`
- Returns: Array of union members only

### Update Password
- **POST** `/api/users/update-password`
- Body: `{ "email": "user@example.com", "password": "new_md5_hash" }`
- Returns: `{ "success": true/false }`

### Database Statistics
- **GET** `/api/stats/database`
- Returns: Database statistics (total users, union members, total balance)

## Development

For development with auto-reload:

```bash
npm run dev
```

This requires `nodemon` to be installed (included in devDependencies).

## Troubleshooting

### Connection Error: "connect ECONNREFUSED"
- Check if MySQL server is accessible at `s19.thehost.com.ua:3306`
- Verify database credentials in `.env`
- Test connection: `mysql -h s19.thehost.com.ua -u opad2016 -p`

### CORS Errors
- The backend includes CORS middleware to allow requests from Flutter web
- If you get CORS errors, check that the backend is running on `http://localhost:8000`

### Port Already in Use
- Change `PORT` in `.env` to an available port (e.g., 8001)
- Or kill the process using port 8000: `lsof -ti:8000 | xargs kill -9`

## Production Deployment

For production:

1. Use environment variables instead of `.env` file
2. Enable HTTPS/SSL
3. Add authentication/authorization
4. Use connection pooling (already configured)
5. Add rate limiting
6. Add request validation
7. Use a process manager like PM2

Example PM2 setup:
```bash
npm install -g pm2
pm2 start server.js --name "opad-api"
pm2 save
pm2 startup
```

## Flutter Web Configuration

The Flutter app automatically detects the platform:
- **Web**: Uses API service (HTTP requests to backend)
- **Mobile/Desktop**: Uses direct MySQL connection

The API base URL is configured in `lib/services/api_service.dart`:
```dart
static const String _baseUrl = 'http://localhost:8000/api';
```

Change this to your production backend URL when deploying.

## Database Schema

The backend expects these tables:

### Users Table
```sql
CREATE TABLE Users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  Email VARCHAR(255) UNIQUE,
  Password VARCHAR(255),
  user_id VARCHAR(255)
);
```

### Stats Table
```sql
CREATE TABLE Stats (
  Id VARCHAR(255) PRIMARY KEY,
  Email VARCHAR(255),
  Password VARCHAR(255),
  `Член-профсоюза` INT,
  ФИО VARCHAR(255),
  `Общая сумма` INT
);
```

## Security Notes

- Passwords are hashed with MD5 + salt (same as WordPress)
- The salt is: `fsdfsd6287gf`
- Never expose database credentials in frontend code
- Use HTTPS in production
- Implement proper authentication/authorization
- Add rate limiting to prevent abuse
- Validate all inputs on the backend

## Support

For issues or questions, check:
1. Backend logs: `npm start` output
2. MySQL connection: `mysql -h s19.thehost.com.ua -u opad2016 -p`
3. API health: `curl http://localhost:8000/api/health`
