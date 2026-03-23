import 'package:dio/dio.dart';
import 'package:flutter_opad/utils/k.dart';

import '../utils/logger.dart';

/// Password Reset Service
/// Handles password reset operations via backend API
class PasswordResetService {
  late Dio _dio;

  PasswordResetService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: K.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );
  }

  /// Request password reset - sends reset email
  Future<bool> requestPasswordReset(String email) async {
    try {
      Logger.info('🔐 [RESET] Requesting password reset for: $email');

      final response = await _dio.post(
        'auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        Logger.info('✅ [RESET] Password reset email sent');
        return true;
      }
      Logger.error('❌ [RESET] Failed to request password reset', null);
      return false;
    } catch (e) {
      Logger.error('❌ [RESET] Error requesting password reset', e);
      return false;
    }
  }

  /// Validate reset token
  Future<Map<String, dynamic>?> validateToken(String token) async {
    try {
      Logger.info('🔐 [RESET] Validating token');

      final response = await _dio.post(
        'auth/validate-token',
        data: {'token': token},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        Logger.info('✅ [RESET] Token is valid');
        return response.data;
      }
      Logger.error('❌ [RESET] Invalid or expired token', null);
      return null;
    } catch (e) {
      Logger.error('❌ [RESET] Error validating token', e);
      return null;
    }
  }

  /// Reset password with token
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      Logger.info('🔐 [RESET] Resetting password');

      if (newPassword.length < 6) {
        Logger.error('❌ [RESET] Password too short', null);
        return false;
      }

      final response = await _dio.post(
        'auth/reset-password',
        data: {'token': token, 'password': newPassword},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        Logger.info('✅ [RESET] Password reset successfully');
        return true;
      }
      Logger.error('❌ [RESET] Failed to reset password', null);
      return false;
    } catch (e) {
      Logger.error('❌ [RESET] Error resetting password', e);
      return false;
    }
  }
}
