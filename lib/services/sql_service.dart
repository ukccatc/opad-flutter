import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../data/stats_data.dart';
import '../data/users_data.dart';
import '../models/person_account.dart';
import '../models/person_stats.dart';
import 'api_service.dart';
import 'mysql_service.dart';

/// SQL Service for accessing data from MySQL database
/// Falls back to local data from Users.sql and Stats.sql files for backward compatibility
///
/// Database Structure:
/// - Users table: id, email, password (MD5), user_id
/// - Stats table: Id (varchar), email, password (MD5), Член-профсоюза, ФИО, Общая сумма
class SqlService {
  final MySqlService _mysqlService = MySqlService();
  final ApiService _apiService = ApiService();
  late bool _useApi;

  /// Initialize database connection (API for web, MySQL for mobile)
  Future<void> initialize() async {
    _useApi = kIsWeb; // Use API for web, MySQL for mobile/desktop

    if (_useApi) {
      try {
        await _apiService.initialize();
      } catch (e) {
        print('⚠️ API connection failed, will use local data: $e');
      }
    } else {
      try {
        await _mysqlService.connect();
      } catch (e) {
        print('⚠️ MySQL connection failed, will use local data: $e');
      }
    }
  }

  /// Get person account details by email (API/MySQL first, fallback to local)
  Future<PersonAccount> getPersonAccount(String email) async {
    // Try API first if web
    if (_useApi && _apiService.isConnected) {
      try {
        return await _apiService.getPersonAccount(email);
      } catch (e) {
        print('⚠️ API getPersonAccount failed, falling back to local: $e');
      }
    }

    // Try MySQL if mobile/desktop
    if (!_useApi && _mysqlService.isConnected) {
      try {
        return await _mysqlService.getPersonAccount(email);
      } catch (e) {
        print('⚠️ MySQL getPersonAccount failed, falling back to local: $e');
      }
    }

    // Fallback to local data
    final userData = UsersData.findByEmail(email);
    if (userData == null) {
      throw Exception('User not found: $email');
    }

    return PersonAccount.fromJson(userData);
  }

  /// Get person statistics by email or ID (API/MySQL first, fallback to local)
  Future<PersonStats> getPersonStatsFromSql(String emailOrId) async {
    // Try API first if web
    if (_useApi && _apiService.isConnected) {
      try {
        return await _apiService.getPersonStats(emailOrId);
      } catch (e) {
        print('⚠️ API getPersonStats failed, falling back to local: $e');
      }
    }

    // Try MySQL if mobile/desktop
    if (!_useApi && _mysqlService.isConnected) {
      try {
        return await _mysqlService.getPersonStats(emailOrId);
      } catch (e) {
        print('⚠️ MySQL getPersonStats failed, falling back to local: $e');
      }
    }

    // Fallback to local data
    final statsData = StatsData.findByEmailOrId(emailOrId);
    if (statsData == null) {
      throw Exception('Stats not found for: $emailOrId');
    }

    return PersonStats.fromJson(statsData);
  }

  /// Authenticate person (API/MySQL first, fallback to local)
  /// Validates email and MD5 password hash
  Future<bool> authenticatePerson(String email, String password) async {
    // Try API first if web
    if (_useApi && _apiService.isConnected) {
      try {
        return await _apiService.authenticatePerson(email, password);
      } catch (e) {
        print('⚠️ API authentication failed, falling back to local: $e');
      }
    }

    // Try MySQL if mobile/desktop
    if (!_useApi && _mysqlService.isConnected) {
      try {
        return await _mysqlService.authenticateUser(email, password);
      } catch (e) {
        print('⚠️ MySQL authentication failed, falling back to local: $e');
      }
    }

    // Fallback to local data
    final userData = UsersData.findByEmail(email);
    if (userData == null) {
      return false;
    }

    final passwordHash = _md5Hash(password);
    final storedHash = userData['Password'] as String? ?? '';
    return passwordHash.toLowerCase() == storedHash.toLowerCase();
  }

  /// MD5 hash function using crypto package (same as WordPress)
  String _md5Hash(String input) {
    final secret = 'fsdfsd6287gf'; // From WordPress functions.php
    final bytes = utf8.encode(secret + input);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Get all users from API/MySQL or local data
  Future<List<PersonStats>> getAllUsers() async {
    if (_useApi && _apiService.isConnected) {
      try {
        return await _apiService.getAllUsers();
      } catch (e) {
        print('⚠️ API getAllUsers failed: $e');
      }
    }

    if (!_useApi && _mysqlService.isConnected) {
      try {
        return await _mysqlService.getAllUsers();
      } catch (e) {
        print('⚠️ MySQL getAllUsers failed: $e');
      }
    }

    // Fallback: convert local data
    return StatsData.stats.map((stat) => PersonStats.fromJson(stat)).toList();
  }

  /// Get union members only
  Future<List<PersonStats>> getUnionMembers() async {
    if (_useApi && _apiService.isConnected) {
      try {
        return await _apiService.getUnionMembers();
      } catch (e) {
        print('⚠️ API getUnionMembers failed: $e');
      }
    }

    if (!_useApi && _mysqlService.isConnected) {
      try {
        return await _mysqlService.getUnionMembers();
      } catch (e) {
        print('⚠️ MySQL getUnionMembers failed: $e');
      }
    }

    // Fallback: filter local data
    return StatsData.stats
        .where((stat) => stat['Член-профсоюза'] == '1')
        .map((stat) => PersonStats.fromJson(stat))
        .toList();
  }

  /// Update user password
  Future<bool> updatePassword(String email, String newPassword) async {
    if (_useApi && _apiService.isConnected) {
      try {
        return await _apiService.updatePassword(email, newPassword);
      } catch (e) {
        print('⚠️ API updatePassword failed: $e');
        return false;
      }
    }

    if (!_useApi && _mysqlService.isConnected) {
      try {
        return await _mysqlService.updatePassword(email, newPassword);
      } catch (e) {
        print('⚠️ MySQL updatePassword failed: $e');
        return false;
      }
    }

    // Can't update local data (read-only)
    print('⚠️ Cannot update password: Database not connected');
    return false;
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    if (_useApi && _apiService.isConnected) {
      try {
        return await _apiService.getDatabaseStats();
      } catch (e) {
        print('⚠️ API getDatabaseStats failed: $e');
      }
    }

    if (!_useApi && _mysqlService.isConnected) {
      try {
        return await _mysqlService.getDatabaseStats();
      } catch (e) {
        print('⚠️ MySQL getDatabaseStats failed: $e');
      }
    }

    // Fallback: calculate from local data
    final stats = StatsData.stats;
    final totalCount = stats.length;
    final unionCount = stats.where((s) => s['Член-профсоюза'] == '1').length;
    final totalBalance = stats.fold<int>(
      0,
      (sum, s) => sum + (s['Общая сумма'] as int),
    );

    return {
      'total_users': totalCount,
      'union_members': unionCount,
      'total_balance': totalBalance,
      'non_union_members': totalCount - unionCount,
    };
  }

  /// Test database connection
  Future<bool> testConnection() async {
    if (_useApi) {
      return await _apiService.testConnection();
    }
    if (_mysqlService.isConnected) {
      return await _mysqlService.testConnection();
    }
    return false;
  }

  /// Close database connection
  Future<void> close() async {
    if (_useApi) {
      await _apiService.close();
    } else {
      await _mysqlService.disconnect();
    }
  }
}
