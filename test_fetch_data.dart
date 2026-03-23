import 'package:flutter_opad/config/database_config.dart';
import 'package:flutter_opad/services/mysql_service.dart';

void main() async {
  print('╔════════════════════════════════════════════════════════════╗');
  print('║     Testing MySQL Connection & Data Retrieval              ║');
  print('╚════════════════════════════════════════════════════════════╝');

  print('\n📋 Database Configuration:');
  print('  Host: ${DatabaseConfig.host}');
  print('  Port: ${DatabaseConfig.port}');
  print('  Database: ${DatabaseConfig.database}');
  print('  Username: ${DatabaseConfig.username}');
  print(
    '  Password: ${DatabaseConfig.password.isNotEmpty ? "✓ Set" : "✗ Not set"}',
  );
  print('  Is Valid: ${DatabaseConfig.isValid ? "✓ Yes" : "✗ No"}');

  final mysqlService = MySqlService();

  try {
    print('\n🔌 Attempting to connect to MySQL...');
    await mysqlService.connect();

    if (mysqlService.isConnected) {
      print('✅ Successfully connected to MySQL!');

      // Test connection
      print('\n🧪 Testing connection...');
      final testResult = await mysqlService.testConnection();
      print('Connection test: ${testResult ? "✅ PASS" : "❌ FAIL"}');

      if (testResult) {
        // Get database stats
        print('\n📊 Database Statistics:');
        try {
          final stats = await mysqlService.getDatabaseStats();
          print('  Total Users: ${stats['total_users']}');
          print('  Union Members: ${stats['union_members']}');
          print('  Non-Union Members: ${stats['non_union_members']}');
          print('  Total Balance: ${stats['total_balance']} грн');
        } catch (e) {
          print('  ⚠️ Error getting stats: $e');
        }

        // Fetch all users from Stats table
        print('\n👥 Fetching Users from Stats Table:');
        try {
          final allUsers = await mysqlService.getAllUsers();
          print('  Total records: ${allUsers.length}');

          if (allUsers.isNotEmpty) {
            print('\n  First 10 users:');
            print(
              '  ┌─────┬──────────────────────────────┬──────────────────────┬────────┬──────────┐',
            );
            print(
              '  │ No. │ Full Name (ФИО)              │ Email                │ Union  │ Amount   │',
            );
            print(
              '  ├─────┼──────────────────────────────┼──────────────────────┼────────┼──────────┤',
            );

            for (
              var i = 0;
              i < (allUsers.length > 10 ? 10 : allUsers.length);
              i++
            ) {
              final user = allUsers[i];
              final name = user.fullName.length > 28
                  ? user.fullName.substring(0, 25) + '...'
                  : user.fullName.padRight(28);
              final email = user.email.length > 20
                  ? user.email.substring(0, 17) + '...'
                  : user.email.padRight(20);
              final union = user.isUnionMember ? 'Yes' : 'No';
              final amount = user.totalAmount.toString().padLeft(8);

              print(
                '  │ ${(i + 1).toString().padLeft(3)} │ $name │ $email │ ${union.padRight(6)} │ $amount │',
              );
            }
            print(
              '  └─────┴──────────────────────────────┴──────────────────────┴────────┴──────────┘',
            );
          }
        } catch (e) {
          print('  ❌ Error fetching users: $e');
        }

        // Fetch union members
        print('\n🏢 Fetching Union Members:');
        try {
          final unionMembers = await mysqlService.getUnionMembers();
          print('  Total union members: ${unionMembers.length}');

          if (unionMembers.isNotEmpty) {
            print('\n  First 5 union members:');
            print(
              '  ┌─────┬──────────────────────────────┬──────────────────────┬──────────┐',
            );
            print(
              '  │ No. │ Full Name (ФИО)              │ Email                │ Amount   │',
            );
            print(
              '  ├─────┼──────────────────────────────┼──────────────────────┼──────────┤',
            );

            for (
              var i = 0;
              i < (unionMembers.length > 5 ? 5 : unionMembers.length);
              i++
            ) {
              final member = unionMembers[i];
              final name = member.fullName.length > 28
                  ? member.fullName.substring(0, 25) + '...'
                  : member.fullName.padRight(28);
              final email = member.email.length > 20
                  ? member.email.substring(0, 17) + '...'
                  : member.email.padRight(20);
              final amount = member.totalAmount.toString().padLeft(8);

              print(
                '  │ ${(i + 1).toString().padLeft(3)} │ $name │ $email │ $amount │',
              );
            }
            print(
              '  └─────┴──────────────────────────────┴──────────────────────┴──────────┘',
            );
          }
        } catch (e) {
          print('  ❌ Error fetching union members: $e');
        }

        // Test authentication
        print('\n🔐 Testing Authentication:');
        try {
          // Try with test user
          const testEmail = 'test@opad.com';
          const testPassword = 'test123';

          print('  Attempting login with: $testEmail');
          final authResult = await mysqlService.authenticateUser(
            testEmail,
            testPassword,
          );

          if (authResult) {
            print('  ✅ Authentication successful!');

            // Get user stats
            try {
              final userStats = await mysqlService.getPersonStatsByEmail(
                testEmail,
              );
              print('\n  User Details:');
              print('    Name: ${userStats.fullName}');
              print('    Email: ${userStats.email}');
              print(
                '    Union Member: ${userStats.isUnionMember ? "Yes" : "No"}',
              );
              print('    Total Amount: ${userStats.totalAmount} грн');
            } catch (e) {
              print('  ⚠️ Could not get user stats: $e');
            }
          } else {
            print('  ❌ Authentication failed for $testEmail');
            print('  (This is expected if test user does not exist)');
          }
        } catch (e) {
          print('  ⚠️ Error during authentication test: $e');
        }

        // Try to fetch a specific user by email
        print('\n🔍 Searching for specific user:');
        try {
          // Get first user from database
          final allUsers = await mysqlService.getAllUsers();
          if (allUsers.isNotEmpty) {
            final firstUser = allUsers.first;
            print('  Searching for: ${firstUser.email}');

            final userStats = await mysqlService.getPersonStatsByEmail(
              firstUser.email,
            );
            print('  ✅ Found user:');
            print('    ID: ${userStats.id}');
            print('    Name: ${userStats.fullName}');
            print('    Email: ${userStats.email}');
            print(
              '    Union Member: ${userStats.isUnionMember ? "Yes" : "No"}',
            );
            print('    Total Amount: ${userStats.totalAmount} грн');
          }
        } catch (e) {
          print('  ⚠️ Error searching for user: $e');
        }
      }
    } else {
      print('❌ Failed to connect to MySQL');
    }

    print('\n🔌 Closing connection...');
    await mysqlService.disconnect();
    print('✅ Connection closed');
  } catch (e) {
    print('\n❌ ERROR: $e');
    print('\n═══════════════════════════════════════════════════════════');
    print('TROUBLESHOOTING GUIDE');
    print('═══════════════════════════════════════════════════════════');
    print('\n1. Verify MySQL Server is Running:');
    print('   - Check if MySQL service is active on ${DatabaseConfig.host}');
    print(
      '   - Try: mysql -h ${DatabaseConfig.host} -u ${DatabaseConfig.username} -p',
    );

    print('\n2. Check Network Connectivity:');
    print('   - Ping the host: ping ${DatabaseConfig.host}');
    print('   - Check if port ${DatabaseConfig.port} is open');
    print('   - Verify firewall rules allow MySQL connections');

    print('\n3. Verify Credentials:');
    print('   - Username: ${DatabaseConfig.username}');
    print('   - Database: ${DatabaseConfig.database}');
    print('   - Check user permissions in MySQL');

    print('\n4. Check MySQL User Permissions:');
    print('   - User must have SELECT, INSERT, UPDATE permissions');
    print('   - User must be allowed to connect from your IP');
    print(
      '   - Run: GRANT ALL ON ${DatabaseConfig.database}.* TO \'${DatabaseConfig.username}\'@\'%\';',
    );

    print('\n5. Alternative Connection Methods:');
    print('   - Try connecting via SSH tunnel');
    print('   - Use phpMyAdmin to verify database access');
    print('   - Check MySQL error logs on the server');

    print('\n6. For Remote Connections:');
    print('   - Ensure MySQL is not bound to localhost only');
    print('   - Check my.cnf: bind-address should not be 127.0.0.1');
    print('   - May need to use SSL/TLS for secure remote connections');
  }

  print('\n╔════════════════════════════════════════════════════════════╗');
  print('║                    Test Complete                           ║');
  print('╚════════════════════════════════════════════════════════════╝');
}
