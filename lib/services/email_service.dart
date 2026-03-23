import 'package:dio/dio.dart';
import 'package:flutter_opad/utils/k.dart';

import '../utils/logger.dart';

/// Email Service for sending emails via backend API
class EmailService {
  late Dio _dio;

  EmailService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: K.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail({
    required String email,
    required String name,
    required String resetLink,
  }) async {
    try {
      Logger.info('📧 Sending password reset email to: $email');
      final response = await _dio.post(
        'email/send-reset',
        data: {'email': email, 'name': name, 'resetLink': resetLink},
      );

      if (response.statusCode == 200) {
        Logger.info('✅ Password reset email sent successfully');
        return true;
      }
      Logger.error('❌ Failed to send password reset email', null);
      return false;
    } catch (e) {
      Logger.error('❌ Error sending password reset email', e);
      return false;
    }
  }

  /// Send welcome email
  Future<bool> sendWelcomeEmail({
    required String email,
    required String name,
  }) async {
    try {
      Logger.info('📧 Sending welcome email to: $email');
      final response = await _dio.post(
        'email/send-welcome',
        data: {'email': email, 'name': name},
      );

      if (response.statusCode == 200) {
        Logger.info('✅ Welcome email sent successfully');
        return true;
      }
      Logger.error('❌ Failed to send welcome email', null);
      return false;
    } catch (e) {
      Logger.error('❌ Error sending welcome email', e);
      return false;
    }
  }

  /// Send notification email
  Future<bool> sendNotificationEmail({
    required String email,
    required String name,
    required String subject,
    required String message,
  }) async {
    try {
      Logger.info('📧 Sending notification email to: $email');
      final response = await _dio.post(
        'email/send-notification',
        data: {
          'email': email,
          'name': name,
          'subject': subject,
          'message': message,
        },
      );

      if (response.statusCode == 200) {
        Logger.info('✅ Notification email sent successfully');
        return true;
      }
      Logger.error('❌ Failed to send notification email', null);
      return false;
    } catch (e) {
      Logger.error('❌ Error sending notification email', e);
      return false;
    }
  }
}
