# Technical Context

## Technology Stack

### Core Framework
- **Flutter SDK**: 3.10.0+
- **Dart SDK**: 3.10.0+
- **Platform**: Web (primary)

### Dependencies

#### Production Dependencies
- `flutter`: SDK framework
- `cupertino_icons`: ^1.0.8 - iOS-style icons
- `dio`: ^5.4.0 - HTTP client for API requests
- `go_router`: ^13.0.0 - Declarative routing (available, not yet used)
- `shared_preferences`: ^2.2.2 - Local storage for authentication
- `url_launcher`: ^6.2.5 - Launch external URLs

#### Development Dependencies
- `flutter_test`: SDK testing framework
- `flutter_lints`: ^6.0.0 - Linting rules

## Backend Integration

### WordPress REST API

**Base URL**: `http://opad.com.ua/wp-json/opad/v1`

**Endpoints**:
1. `GET /posts` - Retrieve WordPress posts/articles
2. `GET /stats/{login}` - Get person statistics by login
3. `POST /auth/login` - Authenticate user

**API Client**: Dio with configuration:
- Base URL: `http://opad.com.ua/wp-json/opad/v1`
- Connect timeout: 10 seconds
- Receive timeout: 10 seconds

### WordPress Backend Details

**WordPress Installation**:
- **Site URL**: `http://opad.com.ua`
- **Installation Path**: `/Users/macbookpro/Git Actions/opad.com.ua/`
- **WordPress Version**: Standard WordPress installation
- **Debug Mode**: Enabled (`WP_DEBUG: true`)
- **Cache**: Enabled (`WP_CACHE: true`)
- **Auto Updates**: Disabled (`WP_AUTO_UPDATE_CORE: false`)

**Database Configuration**:
- **Database Name**: `opad`
- **Database User**: `opad2016`
- **Database Password**: `opad2016`
- **Host**: `localhost`
- **Charset**: `utf8mb4`
- **Collate**: Empty (default)
- **Table Prefix**: `wp_`

**WordPress REST API**:
- **Custom Namespace**: `opad/v1`
- **Base Endpoint**: `http://opad.com.ua/wp-json/opad/v1`
- **Custom Endpoints**:
  - `/posts` - WordPress posts/articles
  - `/stats/{login}` - Person statistics
  - `/auth/login` - Authentication
- **Standard WordPress REST API**: Available at `/wp-json/wp/v2/`

**WordPress Structure**:
- Standard WordPress core files and directories
- Custom REST API endpoints (likely in theme functions or custom plugin)
- WordPress posts stored in `wp_posts` table
- User authentication via WordPress user system
- Custom statistics data (source TBD - custom table or user meta)

**WordPress Content Model**:
- **Posts**: Standard WordPress post type (`post`)
- **Post Meta**: Featured images, custom fields
- **Taxonomies**: Categories, Tags
- **Media**: WordPress media library
- **Attachments**: Linked to posts via post meta

**WordPress Project Files**:
- `wp-config.php`: Main configuration file
- `wp-content/`: Themes, plugins, uploads directory
- `wp-admin/`: WordPress admin interface
- Backup files with `__232b262` suffix indicate version control

## Development Setup

### Prerequisites
- Flutter SDK 3.10.0 or higher
- Dart SDK 3.10.0 or higher
- Web browser (Chrome, Firefox, Safari, Edge)
- Access to WordPress backend (opad.com.ua)

### Installation

```bash
# Install dependencies
flutter pub get

# Run in development mode
flutter run -d chrome

# Build for production
flutter build web
```

### Build Output
- Production build: `build/web/`
- Development server: Runs on localhost with hot reload

## Project Structure

```
flutter-opad/
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── models/                  # Data models
│   │   ├── article.dart
│   │   └── person_stats.dart
│   ├── screens/                 # UI screens
│   │   ├── articles_screen.dart
│   │   ├── login_screen.dart
│   │   └── stats_screen.dart
│   └── services/               # Business logic services
│       ├── api_service.dart
│       └── auth_service.dart
├── web/                        # Web-specific files
│   ├── index.html
│   ├── manifest.json
│   └── icons/
├── test/                       # Test files
│   └── widget_test.dart
├── docs/                       # Documentation
│   ├── projectbrief.md
│   ├── productContext.md
│   ├── activeContext.md
│   ├── systemPatterns.md
│   ├── techContext.md
│   ├── progress.md
│   └── releases/
│       └── current.yaml
├── pubspec.yaml                # Dependencies
├── analysis_options.yaml        # Linting rules
└── README.md                   # Project readme
```

## UI Framework

### Material Design 3
- Using Flutter's Material Design 3 components
- Theme configured with `ColorScheme.fromSeed()`
- Material 3 enabled: `useMaterial3: true`

### Design System
- **Primary Color**: Blue (from seed)
- **Theme**: Material Design 3
- **Icons**: Material Icons + Cupertino Icons
- **Typography**: Material Design typography scale

## State Management

### Current Approach
- **setState()**: Used for local screen state
- **SharedPreferences**: Used for persistent authentication state
- No global state management library yet

### Future Considerations
- `go_router` available for navigation state
- Consider Provider/Riverpod/Bloc if app grows
- Evaluate need for reactive state management

## Data Storage

### Local Storage
- **SharedPreferences**: Used for:
  - Login persistence (`person_login`)
  - Authentication state (`is_logged_in`)

### Remote Storage
- **WordPress Database**: All content and statistics stored in WordPress
- **REST API**: Data fetched on-demand, no local caching yet

## Error Handling

### Current Implementation
- Try-catch blocks in async operations
- Error messages displayed to users
- Retry functionality on error screens

### API Error Handling
- Dio exceptions caught and converted to user-friendly messages
- Network errors handled gracefully
- HTTP errors displayed with context

## Performance Considerations

### Current Optimizations
- Lazy loading of articles (loaded on screen init)
- Image loading with error handling
- Efficient list rendering with ListView.builder

### Future Optimizations
- Implement article caching
- Add pagination for large article lists
- Optimize image loading and caching
- Consider code splitting for web

## Security Considerations

### Authentication
- Login credentials sent via POST (not in URL)
- Session stored locally (SharedPreferences)
- No token refresh mechanism yet

### API Security
- WordPress REST API security handled by backend
- No API keys in client code
- HTTPS should be used in production

## Testing

### Current Test Coverage
- Basic widget test for app initialization
- Smoke test for welcome screen

### Testing Strategy
- Unit tests for services (to be added)
- Widget tests for screens (to be added)
- Integration tests for user flows (to be added)

## Deployment

### Web Deployment
- Build command: `flutter build web`
- Output directory: `build/web/`
- Can be deployed to any static hosting (Netlify, Vercel, etc.)

### Environment Configuration
- API base URL currently hardcoded
- Should be moved to environment variables
- Consider `.env` file or build-time configuration

## Browser Support

### Target Browsers
- Chrome (recommended for development)
- Firefox
- Safari
- Edge

### Flutter Web Limitations
- Some Flutter features may not work on web
- Performance considerations for large lists
- SEO limitations (SPA)

## Development Tools

### IDE Support
- VS Code / Android Studio recommended
- Flutter extensions for IDE
- Dart analyzer for code quality

### Debugging
- Flutter DevTools available
- Browser DevTools for web-specific debugging
- Hot reload for rapid development

## Version Control

### Git Configuration
- `.gitignore` configured for Flutter projects
- Excludes: build/, .dart_tool/, .flutter-plugins-dependencies
- Includes: source code, configuration files

## Future Technical Considerations

1. **Environment Variables**: Move API URLs to environment config
2. **Error Tracking**: Consider Sentry or similar
3. **Analytics**: Add usage analytics if needed
4. **PWA Features**: Enhance web manifest for PWA capabilities
5. **Offline Support**: Implement service worker for offline functionality
6. **Performance Monitoring**: Add performance tracking

