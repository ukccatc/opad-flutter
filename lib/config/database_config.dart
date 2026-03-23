/// Database configuration for direct MySQL connection
/// IMPORTANT: For production, these credentials should be stored securely
/// and not hardcoded in the app
class DatabaseConfig {
  // Database connection details from WordPress wp-config.php
  // Default values for local development
  static String host = 's19.thehost.com.ua'; // MySQL server host
  static int port = 3306;
  static String database = 'opad';
  static String username = 'opad2016';
  static String password = 'opad2016';

  // Connection settings
  static const int connectTimeout = 30; // seconds
  static bool secure = false; // Use SSL for production
  static bool allowInsecure = true; // Allow insecure connections for testing

  // Table names
  static const String statsTable = 'Stats';
  static const String usersTable = 'Users';

  /// Initialize configuration from environment or defaults
  static void initialize({
    String? host,
    int? port,
    String? database,
    String? username,
    String? password,
  }) {
    DatabaseConfig.host = host ?? DatabaseConfig.host;
    DatabaseConfig.port = port ?? DatabaseConfig.port;
    DatabaseConfig.database = database ?? DatabaseConfig.database;
    DatabaseConfig.username = username ?? DatabaseConfig.username;
    DatabaseConfig.password = password ?? DatabaseConfig.password;

    print('Database Config Initialized:');
    print('  Host: ${DatabaseConfig.host}');
    print('  Port: ${DatabaseConfig.port}');
    print('  Database: ${DatabaseConfig.database}');
    print('  Username: ${DatabaseConfig.username}');
    print(
      '  Password: ${DatabaseConfig.password.isNotEmpty ? "******" : "not set"}',
    );
  }

  // Get connection string for debugging
  static String get connectionString {
    return 'mysql://$username:******@$host:$port/$database';
  }

  // Check if we have valid configuration
  static bool get isValid {
    return host.isNotEmpty &&
        database.isNotEmpty &&
        username.isNotEmpty &&
        password.isNotEmpty;
  }
}
