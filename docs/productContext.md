# Product Context

## Problem Space

The OPAD WordPress site (opad.com.ua) serves as a content management and statistics platform. The migration to Flutter aims to:

1. **Modernize Frontend**: Replace WordPress theme with modern Flutter web application
2. **Improve Performance**: Leverage Flutter's performance for better user experience
3. **Maintain Backend**: Keep WordPress as backend CMS while modernizing frontend
4. **Cross-Platform Potential**: Foundation for potential future mobile apps

## Functionality Expectations

### Core Features

#### 1. Articles Display
- **Purpose**: Display WordPress posts/articles to users
- **Data Source**: WordPress REST API (`/wp-json/opad/v1/posts`)
- **Features**:
  - List view with featured images
  - Article metadata (author, date, categories, tags)
  - Attachments display and download
  - External link support
  - Pull-to-refresh functionality

#### 2. Person Statistics
- **Purpose**: Display personalized statistics for logged-in users
- **Data Source**: WordPress REST API (`/wp-json/opad/v1/stats/{login}`)
- **Features**:
  - User-specific statistics display
  - Person information (name, login, last update)
  - Dynamic statistics data visualization
  - Refresh capability

#### 3. Authentication
- **Purpose**: Secure access to person statistics
- **Data Source**: WordPress REST API (`/wp-json/opad/v1/auth/login`)
- **Features**:
  - Login with credentials
  - Session persistence (SharedPreferences)
  - Auto-login on app restart
  - Logout functionality

## UX Goals

### Design Principles
- **Material Design 3**: Modern, consistent UI following Material Design guidelines
- **Responsive**: Adapts to different screen sizes (desktop, tablet)
- **Accessible**: Clear navigation, readable text, proper contrast
- **Performance**: Fast loading, smooth animations, efficient data fetching

### User Flows

1. **Anonymous User Flow**:
   - Land on home screen
   - Browse articles without authentication
   - Access login screen for statistics

2. **Authenticated User Flow**:
   - Login with credentials
   - View personalized statistics
   - Refresh statistics data
   - Logout when done

### Key Screens

- **Home Screen**: Welcome screen with navigation options
- **Articles Screen**: List of articles with details
- **Login Screen**: Authentication form
- **Stats Screen**: Person statistics dashboard

## WordPress Backend Context

### WordPress Installation

**Site URL**: `http://opad.com.ua`
**WordPress Version**: Standard WordPress installation
**Location**: `/Users/macbookpro/Git Actions/opad.com.ua/`

### API Endpoints

**Base URL**: `http://opad.com.ua/wp-json/opad/v1`

1. **GET /posts**
   - Returns list of WordPress posts/articles
   - Includes: title, content, featured image, date, author, categories, tags, attachments, link
   - Supports WordPress REST API standard fields
   - Handles embedded media (`_embedded.wp:featuredmedia`)

2. **GET /stats/{login}**
   - Returns person statistics for given login
   - Includes: person_id, person_name, login, stats (dynamic object), last_update
   - Custom endpoint for person-specific statistics
   - Data likely sourced from custom database tables or WordPress user meta

3. **POST /auth/login**
   - Authenticates user with login and password
   - Returns: success boolean
   - Custom authentication endpoint (not standard WordPress auth)

### Database Configuration
- **Database Name**: `opad`
- **Database User**: `opad2016`
- **Database Password**: `opad2016`
- **Host**: `localhost`
- **Charset**: `utf8mb4`
- **Collate**: Empty (default)
- **Table Prefix**: `wp_`

### WordPress Configuration Details

**WordPress Settings**:
- `WP_DEBUG`: true (development mode)
- `WP_CACHE`: true (caching enabled)
- `WP_AUTO_UPDATE_CORE`: false (manual updates)
- Custom REST API namespace: `opad/v1`
- Custom endpoints for statistics and authentication

**WordPress Structure**:
- Standard WordPress core files
- Custom REST API endpoints in `wp-content/plugins/` or theme functions
- WordPress posts stored in `wp_posts` table
- User data in `wp_users` table
- Custom statistics likely in custom tables or user meta

**WordPress Content**:
- Posts/Articles: Standard WordPress post type
- Categories: WordPress taxonomy
- Tags: WordPress taxonomy
- Attachments: WordPress media library
- Featured Images: WordPress post meta (`_thumbnail_id`)

### Migration Context

**Source System**: WordPress CMS
- Content managed through WordPress admin
- Posts published via WordPress interface
- Media uploaded through WordPress media library
- User authentication via WordPress user system

**Target System**: Flutter Web Application
- Frontend built with Flutter
- Data consumed via WordPress REST API
- No direct database access
- Authentication via custom API endpoint

**Data Flow**:
```
WordPress Database (MySQL)
  └─> WordPress REST API
      └─> Flutter ApiService (Dio)
          └─> Flutter Models
              └─> Flutter UI Screens
```

### WordPress Project Files

**Key WordPress Files**:
- `wp-config.php`: Database and WordPress configuration
- `index.php`: WordPress entry point
- `wp-content/`: Themes, plugins, uploads
- `wp-admin/`: WordPress admin interface
- Custom REST API endpoints (location TBD)

**Backup Files**: 
- Multiple `__232b262` suffixed files indicate backup/version control
- Original WordPress files preserved alongside active files

