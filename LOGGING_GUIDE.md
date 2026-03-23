# Logging Guide - Login & Password Reset

## Overview

Comprehensive logging has been added to track the login and password reset processes. This helps debug issues when things aren't working.

## Where to Find Logs

### Backend Logs
**Terminal where you run `npm start`:**
```bash
cd flutter-opad/backend
npm start
```

Look for messages like:
```
🔐 [AUTH] Login attempt for: user@example.com
✅ [AUTH] User found in Users table
```

### Frontend Logs
**Browser Console (F12):**
- Press `F12` in Chrome
- Go to "Console" tab
- Look for messages like:
```
🔐 [AUTH] Starting authentication for: user@example.com
✅ [AUTH] Authentication result: true
```

## Login Process Logs

### Frontend (Flutter Web App)

```
🔐 [LOGIN] Attempting login for: user@example.com
🔐 [LOGIN] Password length: 8
🔐 [AUTH] Starting authentication for: user@example.com
🔐 [AUTH] Password hash: a1b2c3d4...
🔐 [AUTH] Response status: 200
🔐 [AUTH] Response data: {"success":true}
🔐 [AUTH] Authentication result: true
✅ [LOGIN] Login successful for: user@example.com
💾 [LOGIN] Login saved to storage
🔄 [LOGIN] Navigating to stats page
```

### Backend (Node.js Server)

```
🔐 [AUTH] Login attempt for: user@example.com
🔐 [AUTH] Password hash: a1b2c3d4...
✅ [AUTH] Database connection established
🔍 [AUTH] Checking Users table for: user@example.com
✅ [AUTH] User found in Users table
```

## Password Reset Process Logs

### Frontend - Sending Reset Email

```
📧 [RESET] Starting password reset for: user@example.com
✅ [RESET] Rate limit check passed
🔍 [RESET] Checking if email exists in database...
✅ [RESET] Email found in database
🔑 [RESET] Generated reset token: a1b2c3d4...
💾 [RESET] Token saved to SharedPreferences
🔗 [RESET] Reset link: http://localhost:54744/#/reset-password?email=user@example.com&token=a1b2c3d4...
📤 [RESET] Sending email via EmailJS...
📬 [RESET] EmailJS response status: 200
✅ [RESET] Email sent successfully!
```

### Frontend - Resetting Password

```
🔑 [PASSWORD] Starting password update for: user@example.com
🔑 [PASSWORD] New password hash: b2c3d4e5...
🔑 [PASSWORD] Response status: 200
🔑 [PASSWORD] Response data: {"success":true}
🔑 [PASSWORD] Password update result: true
```

### Backend - Updating Password

```
🔑 [PASSWORD] Password update request for: user@example.com
🔑 [PASSWORD] New password hash: b2c3d4e5...
✅ [PASSWORD] Database connection established
🔄 [PASSWORD] Updating Users table for: user@example.com
🔄 [PASSWORD] Users table update result: 1 rows affected
🔄 [PASSWORD] Updating Stats table for: user@example.com
🔄 [PASSWORD] Stats table update result: 1 rows affected
✅ [PASSWORD] Password updated successfully
```

## Troubleshooting with Logs

### Login Not Working

**Check these logs:**

1. **Frontend logs show error:**
   ```
   ❌ [AUTH] Authentication error: DioException [connection error]
   ```
   → Backend is not running. Start it: `npm start`

2. **Frontend shows "invalid credentials":**
   ```
   ❌ [LOGIN] Authentication failed - invalid credentials
   ```
   → Check backend logs for:
   ```
   ❌ [AUTH] User not found in either table
   ```
   → Email doesn't exist in database

3. **Backend shows connection error:**
   ```
   ❌ [AUTH] Error authenticating user: Error: connect ECONNREFUSED
   ```
   → MySQL server not accessible. Check:
   - MySQL is running
   - Credentials in `backend/.env` are correct
   - Network connection to `s19.thehost.com.ua`

### Password Reset Not Working

**Check these logs:**

1. **Email not sent:**
   ```
   ❌ [RESET] EmailJS returned status 401
   ```
   → EmailJS credentials are wrong. Check:
   - Service ID
   - Template ID
   - Public Key
   - User ID

2. **Email found but not sent:**
   ```
   ✅ [RESET] Email found in database
   📤 [RESET] Sending email via EmailJS...
   ❌ [RESET] EmailJS request failed
   ```
   → Network issue or EmailJS service down

3. **Password update fails:**
   ```
   🔑 [PASSWORD] Password update request for: user@example.com
   ⚠️ [PASSWORD] No rows were updated - user may not exist
   ```
   → User email doesn't exist in database

## Log Levels

| Symbol | Meaning | Action |
|--------|---------|--------|
| 🔐 | Authentication/Security | Normal operation |
| 📧 | Email/Reset | Normal operation |
| 🔑 | Password | Normal operation |
| ✅ | Success | Good - operation worked |
| ⚠️ | Warning | Check this - might be an issue |
| ❌ | Error | Problem - needs fixing |
| 🔍 | Searching/Checking | Normal operation |
| 💾 | Saving/Storage | Normal operation |
| 🔄 | Processing/Updating | Normal operation |
| 📤 | Sending | Normal operation |
| 📬 | Received | Normal operation |

## How to Debug

### Step 1: Open Browser Console
- Press `F12` in Chrome
- Go to "Console" tab
- Keep it open while testing

### Step 2: Open Backend Terminal
- Keep the terminal where you ran `npm start` visible
- Watch for logs as you interact with the app

### Step 3: Perform Action
- Try to login or reset password
- Watch both console and terminal for logs

### Step 4: Read Logs
- Follow the flow from start to end
- Look for ❌ errors
- Check ⚠️ warnings

### Step 5: Fix Issue
- Based on logs, identify the problem
- Fix it (update credentials, restart server, etc.)
- Try again

## Example Debug Session

**Scenario: Login not working**

1. **Browser Console shows:**
   ```
   ❌ [AUTH] Authentication error: DioException [connection error]
   ```

2. **Check backend terminal:**
   - No logs appearing
   - Backend not running

3. **Fix:**
   ```bash
   cd flutter-opad/backend
   npm start
   ```

4. **Try login again:**
   ```
   🔐 [LOGIN] Attempting login for: user@example.com
   🔐 [AUTH] Starting authentication for: user@example.com
   ✅ [AUTH] Authentication result: true
   ✅ [LOGIN] Login successful
   ```

5. **Success!** ✅

## Common Issues & Solutions

| Issue | Log Message | Solution |
|-------|-------------|----------|
| Backend not running | `DioException [connection error]` | Run `npm start` in backend |
| Wrong credentials | `User not found in either table` | Check email/password in database |
| MySQL not accessible | `connect ECONNREFUSED` | Check MySQL server and credentials |
| EmailJS not configured | `EmailJS returned status 401` | Update EmailJS credentials |
| User doesn't exist | `No rows were updated` | Check email exists in database |
| Rate limit exceeded | `Rate limit exceeded` | Wait before trying again |

## Enabling/Disabling Logs

All logs are currently enabled. To disable them:

**Frontend:** Comment out `print()` statements in:
- `lib/services/api_service.dart`
- `lib/screens/login_screen.dart`
- `lib/services/password_reset_service.dart`

**Backend:** Comment out `console.log()` statements in:
- `backend/server.js`

## Next Steps

1. ✅ Open browser console (F12)
2. ✅ Watch backend terminal
3. ✅ Try login
4. ✅ Check logs
5. ✅ Fix any issues
6. ✅ Test password reset

Good luck! 🚀
