# OPAD Flutter Web Application

Flutter web application for OPAD project - migration from WordPress.

## Project Overview

This Flutter project is designed primarily for web platform and will integrate with WordPress backend to fetch and display data.

## Getting Started

### Prerequisites

- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.10.0 or higher)
- Web browser (Chrome, Firefox, Safari, or Edge)

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the application:
```bash
flutter run -d chrome
```

### Build for Production

Build the web application:
```bash
flutter build web
```

The build output will be in the `build/web` directory.

## Project Structure

```
lib/
├── main.dart          # Application entry point
├── models/           # Data models (to be created)
├── services/         # API services (to be created)
└── screens/          # UI screens (to be created)
```

## Next Steps

1. Set up WordPress REST API endpoints
2. Create data models for WordPress data
3. Implement API service layer
4. Build UI screens for displaying data
5. Integrate statistics data from SQL database

## Development

This project uses Flutter's Material Design 3 and is optimized for web platform.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/).
