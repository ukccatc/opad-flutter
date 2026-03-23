import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sql_service.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

/// Global utility class for application constants and service discovery
class K {
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  /// Show a snackbar with optional error styling
  static void showSnackBar(String message, {bool isError = false}) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.blue,
      ),
    );
  }

  /// Get logic class from context using `Provider.of<T>(context, listen: false)`
  static T logic<T>(BuildContext context) => Provider.of<T>(context, listen: false);
  
  /// Get logic class (Read only) - Shortcut for `context.read<T>()`
  /// Based on user rules: Access via `K.logicR<MyLogic>()`
  static T logicR<T>(BuildContext context) => context.read<T>();

  /// Access logic class (Watch for changes) - Shortcut for `context.watch<T>()`
  static T logicW<T>(BuildContext context) => context.watch<T>();

  /// Access global singleton services
  static SqlService get sqlService => SqlService();
  static AuthService get authService => AuthService();
  static ApiService get apiService => ApiService();

  // App Strings and Links (Placeholders for rules)
  static const String appDownloadLink = 'https://opad.com.ua/download';
  static const String appDownloadLinkAndroid = 'https://play.google.com/store/apps/details?id=ua.com.opad';
  static const String appDownloadLinkIOS = 'https://apps.apple.com/app/opad/id1234567890';
}
