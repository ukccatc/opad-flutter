import 'package:flutter/foundation.dart';

/// Global logger utility as per project rules
class Logger {
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('INFO: $message');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('ERROR: $message');
      if (error != null) debugPrint(error.toString());
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('WARNING: $message');
    }
  }
}
