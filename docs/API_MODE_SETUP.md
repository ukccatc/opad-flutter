# API Mode Setup - Local vs Production

This guide explains how to use the new local/production server switching functionality.

## What Was Added

1. **ApiConfig** (`lib/config/api_config.dart`) - Singleton configuration manager
2. **ApiModeSwitcher** (`lib/widgets/api_mode_switcher.dart`) - UI widget to toggle modes
3. **Enhanced ApiService** - Updated to support both local and production servers

## Configuration

### Default URLs
- **Production**: `https://opad.com.ua/backend/`
- **Local**: `http://localhost:3000/backend/`

To change the local URL, edit `lib/services/api_service.dart`:
```dart
static const String _localUrl = 'http://localhost:3000/backend/';
```

## Usage

### 1. Initialize in main.dart

Add ApiService initialization:

```dart
import 'package:flutter_opad/services/api_service.dart';
import 'package:flutter_opad/config/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API service with config
  final apiService = ApiService(
    useLocalServer: ApiConfig.instance.useLocalServer,
  );
  await apiService.initialize();
  
  // ... rest of initialization
  
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiService),
        // ... other providers
      ],
      child: const OpadApp(),
    ),
  );
}
```

### 2. Add Mode Switcher to UI

Add the switcher widget to your app bar or settings screen:

```dart
import 'package:flutter_opad/widgets/api_mode_switcher.dart';

// In your app bar or settings:
AppBar(
  title: const Text('ОДЕСЬКА ОБЛАСНА ПРОФСПІЛКА АВІАДИСПЕТЧЕРІВ'),
  actions: [
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: ApiModeSwitcher(
        apiService: apiService,
        onModeChanged: () {
          // Optionally refresh data when mode changes
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('API mode changed')),
          );
        },
      ),
    ),
  ],
)
```

### 3. Programmatic Usage

Switch modes in code:

```dart
import 'package:flutter_opad/config/api_config.dart';

// Switch to local
ApiConfig.instance.setUseLocalServer(true);
apiService.setUseLocalServer(true);

// Switch to production
ApiConfig.instance.setUseLocalServer(false);
apiService.setUseLocalServer(false);

// Toggle
ApiConfig.instance.toggleEnvironment();

// Check current mode
if (ApiConfig.instance.useLocalServer) {
  print('Using LOCAL server');
} else {
  print('Using PRODUCTION server');
}

// Get current URL
print(apiService.currentBaseUrl);
```

## Local Server Setup

To run a local backend server:

1. Ensure your backend is running on `http://localhost:3000`
2. The backend should have the same endpoints as production:
   - `GET /health` - Health check
   - `POST /auth/login` - Authentication
   - `GET /users/account` - Get account
   - `GET /users/stats` - Get stats
   - `GET /users/all` - Get all users
   - `GET /users/union-members` - Get union members
   - `POST /users/update-password` - Update password
   - `GET /stats/database` - Database stats
   - `GET /articles` - Get articles
   - `GET /articles/:id` - Get article by ID

## Visual Indicator

The ApiModeSwitcher widget shows:
- **BLUE** with cloud icon = Production mode
- **ORANGE** with computer icon = Local mode

## Logging

Mode changes are logged with:
```
🔧 API Service initialized with: LOCAL server
🔄 Switched to PRODUCTION server
```

Check the logger output to verify mode switches.
