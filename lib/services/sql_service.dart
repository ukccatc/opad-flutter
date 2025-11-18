import '../models/person_account.dart';
import '../models/person_stats.dart';
import '../data/users_data.dart';
import '../data/stats_data.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// SQL Service for accessing local data from SQL files
/// Uses embedded data from Users.sql and Stats.sql files
/// 
/// Database Structure:
/// - Users table: id, Email, Password (MD5), user_id
/// - Stats table: Id (varchar), Email, Password (MD5), Член-профсоюза, ФИО, Общая сумма
class SqlService {
  /// Get person account details by email from Users table (local data)
  Future<PersonAccount> getPersonAccount(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    final userData = UsersData.findByEmail(email);
    if (userData == null) {
      throw Exception('User not found: $email');
    }

    return PersonAccount.fromJson(userData);
  }

  /// Get person statistics from Stats table by email or ID (local data)
  Future<PersonStats> getPersonStatsFromSql(String emailOrId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    final statsData = StatsData.findByEmailOrId(emailOrId);
    if (statsData == null) {
      throw Exception('Stats not found for: $emailOrId');
    }

    return PersonStats.fromJson(statsData);
  }

  /// Authenticate person using Users table (local data)
  /// Validates email and MD5 password hash
  Future<bool> authenticatePerson(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final userData = UsersData.findByEmail(email);
    if (userData == null) {
      return false;
    }

    // MD5 hash the password for comparison
    final passwordHash = _md5Hash(password);
    final storedHash = userData['Password'] as String? ?? '';
    
    return passwordHash.toLowerCase() == storedHash.toLowerCase();
  }

  /// MD5 hash function using crypto package
  String _md5Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
}
