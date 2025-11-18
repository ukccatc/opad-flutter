# OPAD Flutter Project Brief

## Project Vision

OPAD Flutter Web Application is a modern web application built with Flutter, designed to migrate functionality from the existing WordPress-based OPAD system (opad.com.ua). The project aims to provide a responsive, performant web experience while maintaining integration with the WordPress backend infrastructure.

**Source System**: WordPress CMS at `http://opad.com.ua`
- WordPress installation with MySQL database (`opad`)
- Custom REST API endpoints (`/wp-json/opad/v1`)
- Content managed through WordPress admin interface
- User authentication via WordPress user system

**Migration Strategy**: Frontend-only migration
- WordPress remains as backend CMS and API provider
- Flutter application consumes WordPress REST API
- No database migration required
- No WordPress core modifications needed

## Project Goals

1. **Migration from WordPress**: Gradually migrate frontend functionality from WordPress to Flutter while maintaining backend compatibility
2. **Web-First Approach**: Primary platform is web, optimized for modern browsers
3. **WordPress Integration**: Maintain seamless integration with existing WordPress REST API endpoints
4. **User Experience**: Provide modern, responsive UI using Material Design 3
5. **Data Display**: Display articles and person statistics from WordPress backend

## Scope

### In Scope
- Articles display and management
- Person statistics viewing
- User authentication and login
- WordPress REST API integration
- Responsive web UI

### Out of Scope (Current Phase)
- Native mobile apps (iOS/Android)
- WordPress backend modifications
- Database migrations
- Admin panel functionality

## Success Criteria

- Flutter web app successfully displays articles from WordPress
- Person statistics are accessible via login
- Authentication flow works with WordPress backend
- Responsive design works across desktop and tablet viewports
- Application is production-ready for web deployment

## Project Status

**Current Phase**: Initial Development
**Version**: 1.0.0+1
**Platform**: Web (primary)

