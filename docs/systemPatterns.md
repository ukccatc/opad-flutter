# System Patterns & Architecture

## Architecture Overview

The application follows a **layered architecture** pattern:

```
┌─────────────────────────────────┐
│      UI Layer (Screens)         │
│  - HomeScreen                   │
│  - ArticlesScreen               │
│  - LoginScreen                  │
│  - StatsScreen                  │
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│    Service Layer                │
│  - ApiService                   │
│  - AuthService                  │
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│    Model Layer                  │
│  - Article                      │
│  - PersonStats                  │
└─────────────────────────────────┘
```

## Design Patterns

### 1. Service Pattern
**Location**: `lib/services/`

Services encapsulate business logic and external API communication:
- `ApiService`: Handles all HTTP requests to WordPress REST API
- `AuthService`: Manages authentication state and local storage

**Benefits**:
- Separation of concerns
- Reusable across screens
- Easy to test and mock

### 2. Model Pattern
**Location**: `lib/models/`

Data models represent domain entities:
- `Article`: WordPress post structure
- `PersonStats`: Person statistics structure

**Pattern**: Each model includes:
- Factory constructor `fromJson()` for deserialization
- `toJson()` method for serialization
- Nullable fields for optional data

### 3. Screen Pattern
**Location**: `lib/screens/`

Screens follow Flutter StatefulWidget pattern:
- State management using `setState()`
- Async operations in `initState()` or user actions
- Loading and error states

**Common Pattern**:
```dart
class _ScreenState extends State<Screen> {
  bool _isLoading = true;
  String? _error;
  DataModel? _data;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    // Load data with error handling
  }
}
```

## Component Flow

### Article Display Flow

```
HomeScreen
  └─> User taps "View Articles"
      └─> ArticlesScreen
          └─> initState() calls _loadArticles()
              └─> ApiService.getArticles()
                  └─> HTTP GET /wp-json/opad/v1/posts
                      └─> Parse JSON to List<Article>
                          └─> Update UI with articles
```

### Authentication Flow

```
HomeScreen
  └─> User taps "Person Statistics"
      └─> LoginScreen
          └─> User enters credentials
              └─> ApiService.loginPerson()
                  └─> HTTP POST /wp-json/opad/v1/auth/login
                      └─> On success: AuthService.saveLogin()
                          └─> Navigate to StatsScreen
                              └─> ApiService.getPersonStats()
                                  └─> HTTP GET /wp-json/opad/v1/stats/{login}
                                      └─> Display statistics
```

### Auto-Login Flow

```
App Start
  └─> HomeScreen.initState()
      └─> AuthService.isLoggedIn()
          └─> If true: AuthService.getLogin()
              └─> Navigate directly to StatsScreen
```

## Data Flow

### API Request Flow

1. **Screen** initiates request
2. **Service** constructs HTTP request
3. **Dio** sends HTTP request
4. **WordPress** processes request
5. **Response** parsed to Model
6. **Screen** updates UI

### State Management Flow

Currently using **setState()** pattern:
- Each screen manages its own state
- Loading, error, and data states
- No global state management yet

**Future Consideration**: 
- If app grows, consider Provider/Riverpod/Bloc
- For now, setState() is sufficient

## Key Design Decisions

### 1. Stateless Services
Services are instantiated per screen, not singletons. This allows:
- Easy testing
- No global state issues
- Clear dependencies

### 2. Nullable Models
Models use nullable fields for optional WordPress data:
- Handles missing fields gracefully
- Prevents crashes on incomplete data
- Provides default values where appropriate

### 3. Error Handling Pattern
Each screen implements:
- Loading state (`_isLoading`)
- Error state (`_error`)
- Retry functionality
- User-friendly error messages

### 4. Navigation Pattern
Currently using `Navigator.push()`:
- Simple and straightforward
- Works well for current scope
- `go_router` available for future migration

## File Naming Conventions

- **Screens**: `{name}_screen.dart` (e.g., `articles_screen.dart`)
- **Services**: `{name}_service.dart` (e.g., `api_service.dart`)
- **Models**: `{name}.dart` (e.g., `article.dart`)
- **Widgets**: `{name}_widget.dart` (future)

## Code Organization

```
lib/
├── main.dart              # App entry point
├── models/               # Data models
│   ├── article.dart
│   └── person_stats.dart
├── screens/              # UI screens
│   ├── articles_screen.dart
│   ├── login_screen.dart
│   └── stats_screen.dart
└── services/            # Business logic
    ├── api_service.dart
    └── auth_service.dart
```

## WordPress Integration Patterns

### API Communication Pattern

**Current Implementation**:
- Direct API calls from screens to `ApiService`
- Dio HTTP client handles all WordPress REST API requests
- Models handle JSON parsing from WordPress response format

**WordPress Response Handling**:
- WordPress REST API returns standard WordPress post format
- `Article.fromJson()` handles both standard and custom WordPress formats
- Supports embedded media (`_embedded.wp:featuredmedia`)
- Handles WordPress date formats (`date`, `date_gmt`)

**Error Handling**:
- WordPress API errors caught and converted to user-friendly messages
- Network errors handled gracefully
- HTTP status codes interpreted appropriately

### Data Mapping Pattern

**WordPress to Flutter Model Mapping**:
```
WordPress Post
  ├─> id → Article.id
  ├─> title.rendered → Article.title
  ├─> content.rendered → Article.content
  ├─> featured_media → Article.featuredImage
  ├─> date → Article.date
  ├─> author → Article.author
  ├─> excerpt.rendered → Article.excerpt
  ├─> categories → Article.categories
  ├─> tags → Article.tags
  └─> link → Article.link
```

**Custom Endpoints**:
- Statistics endpoint (`/stats/{login}`) returns custom format
- Authentication endpoint (`/auth/login`) returns simple success boolean
- Both endpoints are custom WordPress REST API extensions

## Future Architecture Considerations

1. **State Management**: Evaluate need for Provider/Riverpod
2. **Dependency Injection**: Consider get_it or similar
3. **Repository Pattern**: Add repository layer between services and models
4. **Caching Layer**: Implement local caching for articles
5. **Error Handling**: Centralized error handling service
6. **WordPress Sync**: Consider background sync for articles
7. **Offline Support**: Cache WordPress content for offline access

