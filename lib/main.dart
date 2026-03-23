import 'package:flutter/material.dart';
import 'package:flutter_opad/logic/l_email.dart';
import 'package:flutter_opad/logic/l_password_reset.dart';
import 'package:provider/provider.dart';

import 'config/database_config.dart';
import 'logic/l_articles.dart';
import 'logic/l_billing_profile.dart';
import 'logic/l_files.dart';
import 'logic/l_home.dart';
import 'logic/l_login.dart';
import 'logic/l_stats.dart';
import 'router/app_router.dart';
import 'services/sql_service.dart';
import 'utils/k.dart';
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database configuration
  DatabaseConfig.initialize();

  // Initialize MySQL connection
  final sqlService = SqlService();
  try {
    await sqlService.initialize();
    Logger.info('✅ MySQL connection initialized');

    // Test connection
    final isConnected = await sqlService.testConnection();
    if (isConnected) {
      Logger.info('✅ MySQL connection test successful');
    } else {
      Logger.warning('⚠️ MySQL connection test failed, using local data');
    }
  } catch (e) {
    Logger.error('⚠️ MySQL initialization error', e);
    Logger.warning('⚠️ Will use local data only');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginLogic()),
        ChangeNotifierProvider(create: (_) => HomeLogic()),
        ChangeNotifierProvider(create: (_) => ArticlesLogic()),
        ChangeNotifierProvider(create: (_) => StatsLogic()),
        ChangeNotifierProvider(create: (_) => BillingProfileLogic()),
        ChangeNotifierProvider(create: (_) => FilesLogic()),
        ChangeNotifierProvider(create: (_) => EmailLogic()),
        ChangeNotifierProvider(create: (_) => PasswordResetLogic()),
      ],
      child: const OpadApp(),
    ),
  );
}

class OpadApp extends StatelessWidget {
  const OpadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ОДЕСЬКА ОБЛАСНА ПРОФСПІЛКА АВІАДИСПЕТЧЕРІВ',
      scaffoldMessengerKey: K.messengerKey,
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
          surfaceContainerHighest: const Color(0xFFF5F5F5), // Light gray
          onSurfaceVariant: const Color(0xFF616161),

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
          color: Colors.white,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color(0xFF0096D6),
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: const Color(0xFF0096D6), width: 1.5),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFFBDBDBD), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFFBDBDBD), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF0096D6), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
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
          iconTheme: const IconThemeData(color: Colors.white),
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
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF1A1A1A),
          contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 4,
        ),
        dividerTheme: DividerThemeData(
          color: const Color(0xFFE0E0E0),
          thickness: 1,
          space: 1,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFF5F5F5),
          selectedColor: const Color(
            0xFFB3E5FC,
          ), // Light sky blue (primaryContainer) for better visibility
          disabledColor: const Color(0xFFE0E0E0),
          deleteIconColor: const Color(0xFF616161),
          labelStyle: TextStyle(
            color: const Color(0xFF616161),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          secondaryLabelStyle: const TextStyle(
            color: Color(
              0xFF003D82,
            ), // Dark blue text on light blue background for better contrast
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFF0096D6).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
