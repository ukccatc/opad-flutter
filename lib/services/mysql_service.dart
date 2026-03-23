import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:mysql1/mysql1.dart';

import '../config/database_config.dart';
import '../models/m_person_account.dart';
import '../models/m_person_stats.dart';
import '../utils/logger.dart';

/// Direct MySQL Service for connecting to WordPress database
/// This service provides direct database access for user authentication and data retrieval
class MySqlService {
  MySqlConnection? _connection;
  bool _isConnected = false;

  /// Connect to MySQL database
  Future<void> connect() async {
    try {
      if (_isConnected && _connection != null) {
        return;
      }

      Logger.info(
        'Connecting to MySQL at ${DatabaseConfig.host}:${DatabaseConfig.port}...',
      );

      final settings = ConnectionSettings(
        host: DatabaseConfig.host,
        port: DatabaseConfig.port,
        user: DatabaseConfig.username,
        password: DatabaseConfig.password,
        db: DatabaseConfig.database,
      );

      _connection = await MySqlConnection.connect(settings);
      _isConnected = true;

      Logger.info('✅ MySQL connected successfully to ${DatabaseConfig.host}');
    } catch (e) {
      _isConnected = false;
      _connection = null;
      Logger.error('❌ MySQL connection error', e);
      rethrow;
    }
  }

  /// Close database connection
  Future<void> disconnect() async {
    try {
      await _connection?.close();
      _isConnected = false;
      _connection = null;
      Logger.info('✅ MySQL connection closed');
    } catch (e) {
      Logger.error('❌ Error closing MySQL connection', e);
    }
  }

  /// Check if connected to database
  bool get isConnected => _isConnected;

  /// Get person account details by email
  Future<PersonAccount> getPersonAccount(String email) async {
    await _ensureConnected();

    try {
      final results = await _connection!.query(
        'SELECT * FROM ${DatabaseConfig.usersTable} WHERE Email = ?',
        [email],
      );

      if (results.isEmpty) {
        throw Exception('User not found: $email');
      }

      final row = results.first;
      return PersonAccount.fromJson({
        'id': row['id'],
        'Email': row['Email'],
        'Password': row['Password'],
        'user_id': row['user_id'],
      });
    } catch (e) {
      Logger.error('❌ Error getting person account', e);
      rethrow;
    }
  }

  /// Get person statistics by email
  Future<PersonStats> getPersonStatsByEmail(String email) async {
    await _ensureConnected();

    try {
      final results = await _connection!.query(
        'SELECT * FROM ${DatabaseConfig.statsTable} WHERE Email = ?',
        [email],
      );

      if (results.isEmpty) {
        throw Exception('Stats not found for email: $email');
      }

      final row = results.first;
      return _convertRowToPersonStats(row);
    } catch (e) {
      Logger.error('❌ Error getting person stats by email', e);
      rethrow;
    }
  }

  /// Get person statistics by ID
  Future<PersonStats> getPersonStatsById(String id) async {
    await _ensureConnected();

    try {
      final results = await _connection!.query(
        'SELECT * FROM ${DatabaseConfig.statsTable} WHERE Id = ?',
        [id],
      );

      if (results.isEmpty) {
        throw Exception('Stats not found for ID: $id');
      }

      final row = results.first;
      return _convertRowToPersonStats(row);
    } catch (e) {
      Logger.error('❌ Error getting person stats by ID', e);
      rethrow;
    }
  }

  /// Get person statistics by email or ID
  Future<PersonStats> getPersonStats(String emailOrId) async {
    try {
      // Try by email first
      return await getPersonStatsByEmail(emailOrId);
    } catch (e) {
      // If not found by email, try by ID
      return await getPersonStatsById(emailOrId);
    }
  }

  /// Authenticate user with email and password
  Future<bool> authenticateUser(String email, String password) async {
    await _ensureConnected();

    try {
      // First check in Users table
      final userResults = await _connection!.query(
        'SELECT * FROM ${DatabaseConfig.usersTable} WHERE Email = ? AND Password = ?',
        [email, _md5Hash(password)],
      );

      if (userResults.isNotEmpty) {
        return true;
      }

      // Also check in Stats table (some users might only be in Stats)
      final statsResults = await _connection!.query(
        'SELECT * FROM ${DatabaseConfig.statsTable} WHERE Email = ? AND Password = ?',
        [email, _md5Hash(password)],
      );

      return statsResults.isNotEmpty;
    } catch (e) {
      Logger.error('❌ Authentication error', e);
      return false;
    }
  }

  /// Get all users (for admin purposes)
  Future<List<PersonStats>> getAllUsers() async {
    await _ensureConnected();

    try {
      final results = await _connection!.query(
        'SELECT * FROM ${DatabaseConfig.statsTable} ORDER BY ФИО',
      );

      return results.map((row) => _convertRowToPersonStats(row)).toList();
    } catch (e) {
      Logger.error('❌ Error getting all users', e);
      rethrow;
    }
  }

  /// Get union members only
  Future<List<PersonStats>> getUnionMembers() async {
    await _ensureConnected();

    try {
      final results = await _connection!.query(
        'SELECT * FROM ${DatabaseConfig.statsTable} WHERE `Член-профсоюза` = 1 ORDER BY ФИО',
      );

      return results.map((row) => _convertRowToPersonStats(row)).toList();
    } catch (e) {
      Logger.error('❌ Error getting union members', e);
      rethrow;
    }
  }

  /// Update user password
  Future<bool> updatePassword(String email, String newPassword) async {
    await _ensureConnected();

    try {
      final passwordHash = _md5Hash(newPassword);

      // Update in Users table
      await _connection!.query(
        'UPDATE ${DatabaseConfig.usersTable} SET Password = ? WHERE Email = ?',
        [passwordHash, email],
      );

      // Update in Stats table
      await _connection!.query(
        'UPDATE ${DatabaseConfig.statsTable} SET Password = ? WHERE Email = ?',
        [passwordHash, email],
      );

      return true;
    } catch (e) {
      Logger.error('❌ Error updating password', e);
      return false;
    }
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    await _ensureConnected();

    try {
      // Get total users count
      final totalResults = await _connection!.query(
        'SELECT COUNT(*) as count FROM ${DatabaseConfig.statsTable}',
      );
      final totalCount = totalResults.first['count'] as int;

      // Get union members count
      final unionResults = await _connection!.query(
        'SELECT COUNT(*) as count FROM ${DatabaseConfig.statsTable} WHERE `Член-профсоюза` = 1',
      );
      final unionCount = unionResults.first['count'] as int;

      // Get total balance sum
      final balanceResults = await _connection!.query(
        'SELECT SUM(`Общая сумма`) as total FROM ${DatabaseConfig.statsTable}',
      );
      final totalBalance = balanceResults.first['total'] as int? ?? 0;

      return {
        'total_users': totalCount,
        'union_members': unionCount,
        'total_balance': totalBalance,
        'non_union_members': totalCount - unionCount,
      };
    } catch (e) {
      Logger.error('❌ Error getting database stats', e);
      rethrow;
    }
  }

  /// Helper method to ensure connection is established
  Future<void> _ensureConnected() async {
    if (!_isConnected || _connection == null) {
      await connect();
    }
  }

  /// Convert database row to PersonStats model
  PersonStats _convertRowToPersonStats(ResultRow row) {
    return PersonStats.fromJson({
      'Id': row['Id'].toString(),
      'Email': row['Email'],
      'Password': row['Password'],
      'Член-профсоюза': row['Член-профсоюза'].toString(),
      'ФИО': row['ФИО'],
      'Общая сумма': row['Общая сумма'],
    });
  }

  /// MD5 hash function (same as WordPress uses)
  String _md5Hash(String input) {
    final secret = 'fsdfsd6287gf'; // From WordPress functions.php
    final bytes = utf8.encode(secret + input);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Test database connection
  Future<bool> testConnection() async {
    try {
      await connect();
      final results = await _connection!.query('SELECT 1 as test');
      final testValue = results.first['test'] as int;
      return testValue == 1;
    } catch (e) {
      Logger.error('❌ Connection test failed', e);
      return false;
    }
  }
}
