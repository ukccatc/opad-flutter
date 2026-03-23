import 'package:flutter_opad/config/database_config.dart';
import 'package:flutter_opad/services/mysql_service.dart';

void main() async {
  print('=== Testing MySQL Connection to ${DatabaseConfig.host} ===');

  final mysqlService = MySqlService();

  try {
    print('Attempting to connect...');
    await mysqlService.connect();

    if (mysqlService.isConnected) {
      print('✅ SUCCESS: Connected to MySQL database!');

      // Test a simple query
      print('Testing simple query...');
      final results = await mysqlService.testConnection();
      print('Connection test: ${results ? "✅ PASS" : "❌ FAIL"}');

      if (results) {
        // Try to get database stats
        try {
          final stats = await mysqlService.getDatabaseStats();
          print('\nDatabase Statistics:');
          print('  Total Users: ${stats['total_users']}');
          print('  Union Members: ${stats['union_members']}');
          print('  Total Balance: ${stats['total_balance']}');
        } catch (e) {
          print('⚠️ Could not get stats: $e');
        }
      }
    } else {
      print('❌ FAILED: Could not connect to MySQL');
    }

    await mysqlService.disconnect();
  } catch (e) {
    print('❌ ERROR: $e');
    print('\n=== Connection Troubleshooting ===');
    print('Host: ${DatabaseConfig.host}');
    print('Port: ${DatabaseConfig.port}');
    print('Database: ${DatabaseConfig.database}');
    print('Username: ${DatabaseConfig.username}');
    print(
      'Password: ${DatabaseConfig.password.isNotEmpty ? "set" : "not set"}',
    );
    print('\nPossible issues:');
    print('1. MySQL server not running or not accessible');
    print('2. Firewall blocking port ${DatabaseConfig.port}');
    print('3. Incorrect credentials');
    print('4. Database user lacks remote access permissions');
    print('5. MySQL server configured to bind to localhost only');
  }

  print('\n=== Test Complete ===');
}
