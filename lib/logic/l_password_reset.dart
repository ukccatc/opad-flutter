import 'package:flutter/material.dart';
import 'package:flutter_opad/config/email_config.dart';
import 'package:flutter_opad/services/password_reset_service.dart';
import 'package:flutter_opad/utils/logger.dart';

/// Password Reset Logic
/// Handles password reset flow and state management
class PasswordResetLogic extends ChangeNotifier {
  final PasswordResetService _service = PasswordResetService();

  bool _isLoading = false;
  String? _error;
  String? _email;
  String? _token;
  bool _tokenValid = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get email => _email;
  String? get token => _token;
  bool get tokenValid => _tokenValid;

  /// Request password reset
  Future<bool> requestReset(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Logger.info('🔐 [RESET] Requesting password reset for: $email');

      // Validate email
      if (!EmailConfig.isValidEmail(email)) {
        _error = 'Invalid email address';
        Logger.error('❌ [RESET] Invalid email format', null);
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Request reset
      final success = await _service.requestPasswordReset(email);

      if (success) {
        _email = email;
        Logger.info('✅ [RESET] Password reset requested');
      } else {
        _error = 'Failed to send reset email';
        Logger.error('❌ [RESET] Failed to request reset', null);
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error: $e';
      Logger.error('❌ [RESET] Error requesting reset', e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Validate reset token
  Future<bool> validateToken(String token) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Logger.info('🔐 [RESET] Validating token');

      final result = await _service.validateToken(token);

      if (result != null && result['success'] == true) {
        _token = token;
        _email = result['email'];
        _tokenValid = true;
        Logger.info('✅ [RESET] Token validated');
      } else {
        _error = 'Invalid or expired token';
        _tokenValid = false;
        Logger.error('❌ [RESET] Token validation failed', null);
      }

      _isLoading = false;
      notifyListeners();
      return _tokenValid;
    } catch (e) {
      _error = 'Error validating token: $e';
      _tokenValid = false;
      Logger.error('❌ [RESET] Error validating token', e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword(String newPassword, String confirmPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Logger.info('🔐 [RESET] Resetting password');

      // Validate inputs
      if (newPassword.isEmpty || confirmPassword.isEmpty) {
        _error = 'Please enter password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (newPassword.length < 6) {
        _error = 'Password must be at least 6 characters';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (newPassword != confirmPassword) {
        _error = 'Passwords do not match';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (_token == null) {
        _error = 'Invalid token';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Reset password
      final success = await _service.resetPassword(_token!, newPassword);

      if (success) {
        Logger.info('✅ [RESET] Password reset successfully');
        _token = null;
        _email = null;
        _tokenValid = false;
      } else {
        _error = 'Failed to reset password';
        Logger.error('❌ [RESET] Failed to reset password', null);
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error: $e';
      Logger.error('❌ [RESET] Error resetting password', e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _isLoading = false;
    _error = null;
    _email = null;
    _token = null;
    _tokenValid = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
