import 'package:flutter_opad/utils/k.dart';

/// API Configuration Manager
/// Manages whether the app uses local or production server
class ApiConfig {
  static final ApiConfig _instance = ApiConfig._internal();

  late bool _useLocalServer;

  ApiConfig._internal() {
    // Initialize from K.useLocalServer setting
    _useLocalServer = K.useLocalServer;
  }

  factory ApiConfig() {
    return _instance;
  }

  /// Get singleton instance
  static ApiConfig get instance => _instance;

  /// Set whether to use local server
  void setUseLocalServer(bool useLocal) {
    _useLocalServer = useLocal;
  }

  /// Check if using local server
  bool get useLocalServer => _useLocalServer;

  /// Get current environment name
  String get environment => _useLocalServer ? 'LOCAL' : 'PRODUCTION';

  /// Toggle between local and production
  void toggleEnvironment() {
    _useLocalServer = !_useLocalServer;
  }
}
