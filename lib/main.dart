import 'package:flutter/material.dart';
import 'router/app_router.dart';

void main() {
  runApp(const OpadApp());
}

class OpadApp extends StatelessWidget {
  const OpadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ОДЕСЬКА ОБЛАСНА ПРОФСПІЛКА АВІАДИСПЕТЧЕРІВ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          // Aviation sky blue as primary color
          primary: const Color(0xFF0096D6), // Sky blue
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFB3E5FC), // Light sky blue
          onPrimaryContainer: const Color(0xFF003D82), // Deep sky blue
          
          // Orange/amber for accents (navigation lights, warnings)
          secondary: const Color(0xFFFF6B35), // Aviation orange
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFFFE0B2), // Light orange
          onSecondaryContainer: const Color(0xFFE65100), // Dark orange
          
          // Tertiary - deep blue (sky depth)
          tertiary: const Color(0xFF003D82), // Deep sky blue
          onTertiary: Colors.white,
          tertiaryContainer: const Color(0xFFE3F2FD), // Very light blue
          onTertiaryContainer: const Color(0xFF001B3D), // Very deep blue
          
          // Error - red for aviation alerts
          error: const Color(0xFFD32F2F), // Aviation red
          onError: Colors.white,
          errorContainer: const Color(0xFFFFCDD2), // Light red
          onErrorContainer: const Color(0xFFB71C1C), // Dark red
          
          // Surface colors - white/light gray (clouds, aircraft metal)
          surface: Colors.white,
          onSurface: const Color(0xFF1A1A1A), // Dark gray for text
          surfaceVariant: const Color(0xFFF5F5F5), // Light gray
          onSurfaceVariant: const Color(0xFF616161), // Medium gray
          
          // Background - very light sky blue
          background: const Color(0xFFF0F8FF), // Alice blue (sky)
          onBackground: const Color(0xFF1A1A1A),
          
          // Outline
          outline: const Color(0xFFBDBDBD), // Light gray
          outlineVariant: const Color(0xFFE0E0E0), // Very light gray
          
          // Shadow
          shadow: Colors.black26,
          scrim: Colors.black54,
          inverseSurface: const Color(0xFF1A1A1A),
          onInverseSurface: Colors.white,
          inversePrimary: const Color(0xFFB3E5FC),
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: const Color(0xFF0096D6), // Sky blue background
          foregroundColor: Colors.white, // White text/icons
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: const Color(0xFFF0F8FF), // Alice blue background
          selectedIconTheme: const IconThemeData(
            color: Color(0xFF0096D6), // Sky blue
            size: 28, // Larger icons
          ),
          unselectedIconTheme: const IconThemeData(
            size: 28, // Larger icons
          ),
          selectedLabelTextStyle: const TextStyle(
            color: Color(0xFF0096D6), // Sky blue
            fontWeight: FontWeight.w600,
            fontSize: 16, // Larger text
          ),
          unselectedLabelTextStyle: const TextStyle(
            fontSize: 16, // Larger text
          ),
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
