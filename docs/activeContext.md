# Active Context

## Current Focus

**Status**: Initial Development Phase - Core Features Complete
**Last Updated**: 2024
**WordPress Integration**: Connected to `http://opad.com.ua/wp-json/opad/v1`

## Current Implementation

### Completed Features

1. **Project Setup**
   - Flutter web project initialized
   - Material Design 3 theme configured
   - Basic project structure established

2. **Data Models**
   - `Article` model with full WordPress post structure
   - `ArticleAttachment` model for file attachments
   - `PersonStats` model for statistics data

3. **Services Layer**
   - `ApiService`: HTTP client using Dio for WordPress REST API
   - `AuthService`: Authentication state management using SharedPreferences
   - Base URL: `http://opad.com.ua/wp-json/opad/v1`

4. **UI Screens**
   - `HomeScreen`: Welcome screen with navigation
   - `ArticlesScreen`: Article list with cards, images, attachments
   - `LoginScreen`: Authentication form
   - `StatsScreen`: Person statistics display

5. **Navigation**
   - Basic MaterialApp navigation
   - Route-based navigation between screens
   - Auto-login check on app start

### In Progress

- Testing and validation of API endpoints with actual WordPress backend
- Error handling improvements
- UI polish and responsiveness
- Environment configuration for API URLs

### WordPress Integration Status

**API Connection**:
- Base URL configured: `http://opad.com.ua/wp-json/opad/v1`
- Currently using dummy data (`useDummyData = true` in ApiService)
- Ready to switch to real API when WordPress endpoints are confirmed

**WordPress Backend**:
- WordPress installation located at `/Users/macbookpro/Git Actions/opad.com.ua/`
- Database: `opad` (MySQL, user: `opad2016`)
- Custom REST API namespace: `opad/v1`
- Endpoints expected:
  - `GET /wp-json/opad/v1/posts`
  - `GET /wp-json/opad/v1/stats/{login}`
  - `POST /wp-json/opad/v1/auth/login`

### Pending Decisions

1. **Routing**: Consider migrating to `go_router` (already in dependencies) for better navigation
2. **State Management**: Evaluate need for state management solution (Provider, Riverpod, Bloc)
3. **Error Handling**: Standardize error handling across all API calls
4. **Caching**: Consider implementing article caching for offline support
5. **Environment Configuration**: Move API base URL to environment variables

## Key Decisions Made

1. **Web-First**: Primary platform is web, mobile apps not in current scope
2. **WordPress Backend**: Maintain WordPress as backend, use REST API
3. **Material Design 3**: Use Flutter's Material Design 3 for UI consistency
4. **Dio for HTTP**: Use Dio package for API communication
5. **SharedPreferences**: Use SharedPreferences for local storage (login persistence)

## Technical Debt

1. **Hardcoded API URL**: Base URL is hardcoded in `ApiService`
2. **No Error Recovery**: Limited error handling and retry logic
3. **No Loading States**: Some operations lack proper loading indicators
4. **No Offline Support**: Application requires internet connection
5. **Basic Navigation**: Using basic Navigator instead of go_router

## Next Steps

1. Test all API endpoints with actual WordPress backend
2. Implement proper error handling and user feedback
3. Add loading states for all async operations
4. Consider implementing go_router for navigation
5. Add environment configuration for API URLs
6. Improve responsive design for different screen sizes

