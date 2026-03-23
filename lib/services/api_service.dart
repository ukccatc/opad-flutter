import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_opad/models/m_article.dart';
import 'package:flutter_opad/models/m_person_account.dart';
import 'package:flutter_opad/models/m_person_stats.dart';
import '../utils/logger.dart';

/// API Service for web-compatible database access
/// Uses HTTP requests to a backend API instead of direct MySQL connection
/// This is required for Flutter web since mysql1 package uses RawSocket which isn't supported
class ApiService {
  late Dio _dio;
  static const String _baseUrl =
      'https://opad.com.ua/backend/'; // Production server
  bool _isConnected = false;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );
  }

  /// Initialize API connection (test connectivity)
  Future<void> initialize() async {
    try {
      await testConnection();
      _isConnected = true;
    } catch (e) {
      _isConnected = false;
      Logger.error('⚠️ API connection failed', e);
    }
  }

  /// Check if connected to API
  bool get isConnected => _isConnected;

  /// Get person account details by email
  Future<PersonAccount> getPersonAccount(String email) async {
    try {
      final response = await _dio.get(
        'users/account',
        queryParameters: {'email': email},
      );

      if (response.statusCode == 200) {
        return PersonAccount.fromJson(response.data);
      }
      throw Exception('Failed to get person account: ${response.statusCode}');
    } catch (e) {
      Logger.error('❌ Error getting person account', e);
      rethrow;
    }
  }

  /// Get person statistics by email or ID
  Future<PersonStats> getPersonStats(String emailOrId) async {
    try {
      final response = await _dio.get(
        'users/stats',
        queryParameters: {'emailOrId': emailOrId},
      );

      if (response.statusCode == 200) {
        return PersonStats.fromJson(response.data);
      }
      throw Exception('Failed to get person stats: ${response.statusCode}');
    } catch (e) {
      Logger.error('❌ Error getting person stats', e);
      rethrow;
    }
  }

  /// Authenticate person with email and password
  Future<bool> authenticatePerson(String email, String password) async {
    try {
      Logger.info('🔐 [AUTH] Starting authentication for: $email');
      final passwordHash = _md5Hash(password);
      Logger.info('🔐 [AUTH] Password hash: ${passwordHash.substring(0, 8)}...');

      final response = await _dio.post(
        'auth/login',
        data: {'email': email, 'password': passwordHash},
      );

      Logger.info('🔐 [AUTH] Response status: ${response.statusCode}');
      Logger.info('🔐 [AUTH] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final success = response.data['success'] == true;
        Logger.info('🔐 [AUTH] Authentication result: $success');
        return success;
      }
      Logger.warning('❌ [AUTH] Unexpected status code: ${response.statusCode}');
      return false;
    } catch (e) {
      Logger.error('❌ [AUTH] Authentication error', e);
      rethrow;
    }
  }

  /// Get all users
  Future<List<PersonStats>> getAllUsers() async {
    try {
      final response = await _dio.get('users/all');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => PersonStats.fromJson(item)).toList();
      }
      throw Exception('Failed to get all users: ${response.statusCode}');
    } catch (e) {
      Logger.error('❌ Error getting all users', e);
      rethrow;
    }
  }

  /// Get union members only
  Future<List<PersonStats>> getUnionMembers() async {
    try {
      final response = await _dio.get('users/union-members');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => PersonStats.fromJson(item)).toList();
      }
      throw Exception('Failed to get union members: ${response.statusCode}');
    } catch (e) {
      Logger.error('❌ Error getting union members', e);
      rethrow;
    }
  }

  /// Update user password
  Future<bool> updatePassword(String email, String newPassword) async {
    try {
      final passwordHash = _md5Hash(newPassword);
      final response = await _dio.post(
        'users/update-password',
        data: {'email': email, 'password': passwordHash},
      );

      if (response.statusCode == 200) {
        return response.data['success'] == true;
      }
      return false;
    } catch (e) {
      Logger.error('❌ Error updating password', e);
      return false;
    }
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final response = await _dio.get('stats/database');

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to get database stats: ${response.statusCode}');
    } catch (e) {
      Logger.error('❌ Error getting database stats', e);
      rethrow;
    }
  }

  /// Test API connection
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get('health');
      return response.statusCode == 200;
    } catch (e) {
      Logger.error('❌ API connection test failed', e);
      return false;
    }
  }

  /// Get all articles
  Future<List<Article>> getArticles() async {
    try {
      final response = await _dio.get('articles');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Article.fromJson(item)).toList();
      }
      throw Exception('Failed to get articles: ${response.statusCode}');
    } catch (e) {
      Logger.error('❌ Error getting articles', e);
      rethrow;
    }
  }

  /// Get article by ID
  Future<Article> getArticle(int id) async {
    try {
      final response = await _dio.get('articles/$id');

      if (response.statusCode == 200) {
        return Article.fromJson(response.data);
      }
      throw Exception('Failed to get article: ${response.statusCode}');
    } catch (e) {
      Logger.error('❌ Error getting article', e);
      rethrow;
    }
  }

  /// MD5 hash function (same as WordPress uses)
  String _md5Hash(String input) {
    final secret = 'fsdfsd6287gf'; // From WordPress functions.php
    final bytes = utf8.encode(secret + input);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Close API connection (cleanup)
  Future<void> close() async {
    _dio.close();
  }
}
