// ignore_for_file: avoid_print
import 'package:flutter_opad/config/database_config.dart';
import 'package:flutter_opad/services/mysql_service.dart';

void main() async {
  print('=== Testing MySQL Connection ===');
  print('Database Config:');
  print('  Host: ${DatabaseConfig.host}');
  print('  Port: ${DatabaseConfig.port}');
  print('  Database: ${DatabaseConfig.database}');
  print('  Username: ${DatabaseConfig.username}');
  print(
    '  Password: ${DatabaseConfig.password.isNotEmpty ? "******" : "empty"}',
  );
  print('  Is Valid: ${DatabaseConfig.isValid}');

  final mysqlService = MySqlService();

  try {
    print('\n=== Connecting to MySQL ===');
    await mysqlService.connect();

    if (mysqlService.isConnected) {
      print('✅ Successfully connected to MySQL!');

      // Test connection
      print('\n=== Testing Connection ===');
      final testResult = await mysqlService.testConnection();
      print('Connection test: ${testResult ? "✅ PASS" : "❌ FAIL"}');

      // Get database stats
      print('\n=== Getting Database Statistics ===');
      final stats = await mysqlService.getDatabaseStats();
      print('Total Users: ${stats['total_users']}');
      print('Union Members: ${stats['union_members']}');
      print('Non-Union Members: ${stats['non_union_members']}');
      print('Total Balance: ${stats['total_balance']}');

      // Test authentication with test user
      print('\n=== Testing Authentication ===');
      const testEmail = 'test@opad.com';
      const testPassword = 'test123';

      final authResult = await mysqlService.authenticateUser(
        testEmail,
        testPassword,
      );
      print(
        'Authentication test for $testEmail: ${authResult ? "✅ SUCCESS" : "❌ FAILED"}',
      );

      if (authResult) {
        // Get user stats
        print('\n=== Getting User Statistics ===');
        try {
          final userStats = await mysqlService.getPersonStatsByEmail(testEmail);
          print('User Found: ${userStats.fullName}');
          print('Email: ${userStats.email}');
          print('Union Member: ${userStats.isUnionMember ? "Yes" : "No"}');
          print('Total Amount: ${userStats.totalAmount}');
        } catch (e) {
          print('❌ Error getting user stats: $e');
        }
      }

      // Get all users count
      print('\n=== Getting All Users ===');
      try {
        final allUsers = await mysqlService.getAllUsers();
        print('Total users in database: ${allUsers.length}');

        if (allUsers.isNotEmpty) {
          print('\nFirst 5 users:');
          for (
            var i = 0;
            i < (allUsers.length > 5 ? 5 : allUsers.length);
            i++
          ) {
            final user = allUsers[i];
            print(
              '  ${i + 1}. ${user.fullName} (${user.email}) - ${user.totalAmount} грн',
            );
          }
        }
      } catch (e) {
        print('❌ Error getting all users: $e');
      }

      // Get union members
      print('\n=== Getting Union Members ===');
      try {
        final unionMembers = await mysqlService.getUnionMembers();
        print('Union members count: ${unionMembers.length}');

        if (unionMembers.isNotEmpty) {
          print('\nFirst 5 union members:');
          for (
            var i = 0;
            i < (unionMembers.length > 5 ? 5 : unionMembers.length);
            i++
          ) {
            final member = unionMembers[i];
            print('  ${i + 1}. ${member.fullName} - ${member.totalAmount} грн');
          }
        }
      } catch (e) {
        print('❌ Error getting union members: $e');
      }
    } else {
      print('❌ Failed to connect to MySQL');
    }

    // Close connection
    print('\n=== Closing Connection ===');
    await mysqlService.disconnect();
    print('✅ Connection closed');
  } catch (e) {
    print('❌ Error during MySQL test: $e');
    print('\n=== Troubleshooting Tips ===');
    print('1. Check if MySQL server is running');
    print('2. Verify database credentials in lib/config/database_config.dart');
    print('3. Check if MySQL port 3306 is accessible');
    print('4. Verify database "opad" exists');
    print('5. Check if user "opad2016" has proper permissions');
    print(
      '6. For remote connections, update host from "localhost" to server IP',
    );
  }

  print('\n=== Test Complete ===');
}
