import 'package:flutter/material.dart';
import 'package:flutter_opad/config/email_config.dart';
import 'package:flutter_opad/models/m_email_response.dart';
import 'package:flutter_opad/services/email_service.dart';
import 'package:flutter_opad/utils/logger.dart';

/// Email Logic
/// Handles email operations and state management
class EmailLogic extends ChangeNotifier {
  final EmailService _emailService = EmailService();

  bool _isSending = false;
  String? _lastError;
  EmailResponse? _lastResponse;

  // Getters
  bool get isSending => _isSending;
  String? get lastError => _lastError;
  EmailResponse? get lastResponse => _lastResponse;
  bool get lastOperationSuccess => _lastResponse?.success ?? false;

  /// Send password reset email
  Future<bool> sendPasswordResetEmail({
    required String email,
    required String name,
    required String token,
  }) async {
    try {
      _isSending = true;
      _lastError = null;
      notifyListeners();

      Logger.info('📧 [EMAIL] Sending password reset email to: $email');

      // Validate email
      if (!EmailConfig.isValidEmail(email)) {
        _lastError = 'Invalid email address';
        Logger.error('❌ [EMAIL] Invalid email format', null);
        _isSending = false;
        notifyListeners();
        return false;
      }

      // Generate reset link
      final resetLink = EmailConfig.generateResetLink(token);

      // Send email
      final success = await _emailService.sendPasswordResetEmail(
        email: email,
        name: name,
        resetLink: resetLink,
      );

      if (success) {
        _lastResponse = EmailResponse(
          success: true,
          message: 'Password reset email sent successfully',
        );
        Logger.info('✅ [EMAIL] Password reset email sent');
      } else {
        _lastError = 'Failed to send password reset email';
        Logger.error('❌ [EMAIL] Failed to send password reset email', null);
      }

      _isSending = false;
      notifyListeners();
      return success;
    } catch (e) {
      _lastError = 'Error sending password reset email: $e';
      Logger.error('❌ [EMAIL] Error sending password reset email', e);
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  /// Send welcome email
  Future<bool> sendWelcomeEmail({
    required String email,
    required String name,
  }) async {
    try {
      _isSending = true;
      _lastError = null;
      notifyListeners();

      Logger.info('📧 [EMAIL] Sending welcome email to: $email');

      // Validate email
      if (!EmailConfig.isValidEmail(email)) {
        _lastError = 'Invalid email address';
        Logger.error('❌ [EMAIL] Invalid email format', null);
        _isSending = false;
        notifyListeners();
        return false;
      }

      // Send email
      final success = await _emailService.sendWelcomeEmail(
        email: email,
        name: name,
      );

      if (success) {
        _lastResponse = EmailResponse(
          success: true,
          message: 'Welcome email sent successfully',
        );
        Logger.info('✅ [EMAIL] Welcome email sent');
      } else {
        _lastError = 'Failed to send welcome email';
        Logger.error('❌ [EMAIL] Failed to send welcome email', null);
      }

      _isSending = false;
      notifyListeners();
      return success;
    } catch (e) {
      _lastError = 'Error sending welcome email: $e';
      Logger.error('❌ [EMAIL] Error sending welcome email', e);
      _isSending = false;
      notifyListeners();
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
      _isSending = true;
      _lastError = null;
      notifyListeners();

      Logger.info('📧 [EMAIL] Sending notification email to: $email');

      // Validate email
      if (!EmailConfig.isValidEmail(email)) {
        _lastError = 'Invalid email address';
        Logger.error('❌ [EMAIL] Invalid email format', null);
        _isSending = false;
        notifyListeners();
        return false;
      }

      // Send email
      final success = await _emailService.sendNotificationEmail(
        email: email,
        name: name,
        subject: subject,
        message: message,
      );

      if (success) {
        _lastResponse = EmailResponse(
          success: true,
          message: 'Notification email sent successfully',
        );
        Logger.info('✅ [EMAIL] Notification email sent');
      } else {
        _lastError = 'Failed to send notification email';
        Logger.error('❌ [EMAIL] Failed to send notification email', null);
      }

      _isSending = false;
      notifyListeners();
      return success;
    } catch (e) {
      _lastError = 'Error sending notification email: $e';
      Logger.error('❌ [EMAIL] Error sending notification email', e);
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  /// Clear response
  void clearResponse() {
    _lastResponse = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
