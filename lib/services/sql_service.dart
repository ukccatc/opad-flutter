import '../utils/logger.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/m_person_account.dart';
import '../models/m_person_stats.dart';
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
        Logger.error('⚠️ API connection failed, will use local data', e);
      }
    } else {
      try {
        await _mysqlService.connect();
      } catch (e) {
        Logger.error('⚠️ MySQL connection failed, will use local data', e);
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
        Logger.warning('⚠️ API getPersonAccount failed, falling back to local: $e');
      }
    }

    // Try MySQL if mobile/desktop
    if (!_useApi && _mysqlService.isConnected) {
      try {
        return await _mysqlService.getPersonAccount(email);
      } catch (e) {
        Logger.warning('⚠️ MySQL getPersonAccount failed, falling back to local: $e');
      }
    }

    // Fallback: throw error if no data found
    throw Exception('User not found: $email');
  }

  /// Get person statistics by email or ID (API/MySQL first, fallback to local)
  Future<PersonStats> getPersonStatsFromSql(String emailOrId) async {
    // Try API first if web
    if (_useApi && _apiService.isConnected) {
      try {
        return await _apiService.getPersonStats(emailOrId);
      } catch (e) {
        Logger.warning('⚠️ API getPersonStats failed, falling back to local: $e');
      }
    }

    // Try MySQL if mobile/desktop
    if (!_useApi && _mysqlService.isConnected) {
      try {
        return await _mysqlService.getPersonStats(emailOrId);
      } catch (e) {
        Logger.warning('⚠️ MySQL getPersonStats failed, falling back to local: $e');
      }
    }

    // Fallback: throw error if no data found
    throw Exception('Stats not found for: $emailOrId');
  }

  /// Authenticate person (API/MySQL first, fallback to local)
  /// Validates email and MD5 password hash
  Future<bool> authenticatePerson(String email, String password) async {
    // Try API first if web
    if (_useApi && _apiService.isConnected) {
      try {
        return await _apiService.authenticatePerson(email, password);
      } catch (e) {
        Logger.warning('⚠️ API authentication failed, falling back to local: $e');
      }
    }

    // Try MySQL if mobile/desktop
    if (!_useApi && _mysqlService.isConnected) {
      try {
        return await _mysqlService.authenticateUser(email, password);
      } catch (e) {
        Logger.warning('⚠️ MySQL authentication failed, falling back to local: $e');
      }
    }

    // No local authentication without DB/API
    return false;
  }


  /// Get all users from API/MySQL or local data
  Future<List<PersonStats>> getAllUsers() async {
    if (_useApi && _apiService.isConnected) {
      try {
        return await _apiService.getAllUsers();
      } catch (e) {
        Logger.warning('⚠️ API getAllUsers failed: $e');
      }
    }

    if (!_useApi && _mysqlService.isConnected) {
      try {
        return await _mysqlService.getAllUsers();
      } catch (e) {
        Logger.warning('⚠️ MySQL getAllUsers failed: $e');
      }
    }

    // No local data fallback
    return [];
  }

  /// Get union members only
  Future<List<PersonStats>> getUnionMembers() async {
    if (_useApi && _apiService.isConnected) {
      try {
        return await _apiService.getUnionMembers();
      } catch (e) {
        Logger.warning('⚠️ API getUnionMembers failed: $e');
      }
    }

    if (!_useApi && _mysqlService.isConnected) {
      try {
        return await _mysqlService.getUnionMembers();
      } catch (e) {
        Logger.warning('⚠️ MySQL getUnionMembers failed: $e');
      }
    }

    // No local data fallback
    return [];
  }

  /// Update user password
  Future<bool> updatePassword(String email, String newPassword) async {
    if (_useApi && _apiService.isConnected) {
      try {
        return await _apiService.updatePassword(email, newPassword);
      } catch (e) {
        Logger.error('⚠️ API updatePassword failed', e);
        return false;
      }
    }

    if (!_useApi && _mysqlService.isConnected) {
      try {
        return await _mysqlService.updatePassword(email, newPassword);
      } catch (e) {
        Logger.error('⚠️ MySQL updatePassword failed', e);
        return false;
      }
    }

    // Can't update local data (read-only)
    Logger.warning('⚠️ Cannot update password: Database not connected');
    return false;
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    if (_useApi && _apiService.isConnected) {
      try {
        return await _apiService.getDatabaseStats();
      } catch (e) {
        Logger.warning('⚠️ API getDatabaseStats failed: $e');
      }
    }

    if (!_useApi && _mysqlService.isConnected) {
      try {
        return await _mysqlService.getDatabaseStats();
      } catch (e) {
        Logger.warning('⚠️ MySQL getDatabaseStats failed: $e');
      }
    }

    // No local stats
    return {
      'total_users': 0,
      'union_members': 0,
      'total_balance': 0,
      'non_union_members': 0,
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
