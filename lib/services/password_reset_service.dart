import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'sql_service.dart';
import '../utils/logger.dart';

/// Service for password reset functionality
/// Handles token generation, email sending, and password updates
class PasswordResetService {
  final SqlService _sqlService = SqlService();
  static const String _lastRequestTimeKey = 'password_reset_last_request';
  static const String _resetTokensKey = 'password_reset_tokens';
  static const int _tokenExpirationHours = 24; // Token valid for 24 hours
  static const int _rateLimitMinutes = 1; // Rate limit: 1 request per minute

  /// Initialize the service
  Future<void> initialize() async {
    Logger.info('🔄 [PASSWORD_RESET] Initializing PasswordResetService');
    await _sqlService.initialize();
    Logger.info('✅ [PASSWORD_RESET] PasswordResetService initialized');
  }

  /// Generate a secure reset token
  String _generateResetToken(String email) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = '$email$timestamp';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Save reset token with expiration (using SharedPreferences)
  Future<void> _saveResetToken(String email, String token) async {
    final prefs = await SharedPreferences.getInstance();
    final tokens = prefs.getStringList(_resetTokensKey) ?? [];

    // Remove old tokens for this email
    final newTokens = tokens.where((t) {
      try {
        final data = jsonDecode(t);
        return data['email'] != email;
      } catch (e) {
        return true;
      }
    }).toList();

    // Add new token
    final tokenData = {
      'email': email,
      'token': token,
      'expiresAt': DateTime.now()
          .add(Duration(hours: _tokenExpirationHours))
          .toIso8601String(),
      'used': false,
    };

    newTokens.add(jsonEncode(tokenData));
    await prefs.setStringList(_resetTokensKey, newTokens);
  }

  /// Verify reset token (using SharedPreferences)
  Future<bool> verifyResetToken(String email, String token) async {
    final prefs = await SharedPreferences.getInstance();
    final tokens = prefs.getStringList(_resetTokensKey) ?? [];

    for (var tokenJson in tokens) {
      try {
        final data = jsonDecode(tokenJson);
        if (data['email'] == email &&
            data['token'] == token &&
            data['used'] == false) {
          final expiresAt = DateTime.parse(data['expiresAt']);
          if (DateTime.now().isBefore(expiresAt)) {
            return true;
          }
        }
      } catch (e) {
        continue;
      }
    }

    return false;
  }

  /// Remove used token (mark as used in SharedPreferences)
  Future<void> _removeResetToken(String email, String token) async {
    final prefs = await SharedPreferences.getInstance();
    final tokens = prefs.getStringList(_resetTokensKey) ?? [];
    final newTokens = <String>[];

    for (var tokenJson in tokens) {
      try {
        final data = jsonDecode(tokenJson);
        if (data['email'] == email && data['token'] == token) {
          data['used'] = true;
          newTokens.add(jsonEncode(data));
        } else {
          newTokens.add(tokenJson);
        }
      } catch (e) {
        newTokens.add(tokenJson);
      }
    }

    await prefs.setStringList(_resetTokensKey, newTokens);
  }

  /// Check if enough time has passed since last password reset request
  /// Returns null if allowed, or seconds remaining if rate limited
  Future<int?> checkRateLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRequestTimeStr = prefs.getString(_lastRequestTimeKey);

    if (lastRequestTimeStr == null) {
      return null; // No previous request, allowed
    }

    final lastRequestTime = DateTime.parse(lastRequestTimeStr);
    final now = DateTime.now();
    final timeSinceLastRequest = now.difference(lastRequestTime);
    final minutesSinceLastRequest = timeSinceLastRequest.inMinutes;

    if (minutesSinceLastRequest >= _rateLimitMinutes) {
      return null; // Enough time has passed, allowed
    }

    // Calculate seconds remaining
    final secondsRemaining =
        (_rateLimitMinutes * 60) - timeSinceLastRequest.inSeconds;
    return secondsRemaining;
  }

  /// Save the time of last password reset request
  Future<void> _saveLastRequestTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _lastRequestTimeKey,
      DateTime.now().toIso8601String(),
    );
  }

  /// Send password reset email using EmailJS
  /// Returns the reset token if successful, null otherwise
  /// Throws RateLimitException if rate limit is exceeded
  /// You need to configure EmailJS service:
  /// 1. Sign up at https://www.emailjs.com/
  /// 2. Create a service (Gmail, Outlook, etc.)
  /// 3. Create an email template
  /// 4. Get your Public Key, Service ID, and Template ID
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      Logger.info('📧 [RESET] Starting password reset for: $email');

      // Check rate limit
      final secondsRemaining = await checkRateLimit();
      if (secondsRemaining != null) {
        Logger.warning(
          '⏱️ [RESET] Rate limit exceeded. Seconds remaining: $secondsRemaining',
        );
        throw RateLimitException(secondsRemaining);
      }

      Logger.info('✅ [RESET] Rate limit check passed');

      // Check if email exists in database (try MySQL first, then fallback to local)
      try {
        Logger.info('🔍 [RESET] Checking if email exists in database...');
        await _sqlService.getPersonAccount(email);
        Logger.info('✅ [RESET] Email found in database');
      } catch (e) {
        // No local fallback
        Logger.warning('❌ [RESET] Email not found in database');
        return null;
      }

      // Generate reset token
      final token = _generateResetToken(email);
      Logger.info('🔑 [RESET] Generated reset token: ${token.substring(0, 8)}...');

      await _saveResetToken(email, token);
      Logger.info('💾 [RESET] Token saved to SharedPreferences');

      // Create reset link
      // For web, we'll use the current origin
      final resetLink = getResetLink(email, token);
      Logger.info('🔗 [RESET] Reset link: $resetLink');

      // EmailJS configuration
      const emailjsServiceId = 'service_c93pzgc';
      const emailjsTemplateId = 'template_sjl6ihm';
      const emailjsPublicKey = 'EBROESqvv299ugyQS';
      const emailjsUserId = 'EBROESqvv299ugyQS';

      // EmailJS API endpoint
      final emailjsUrl = Uri.parse(
        'https://api.emailjs.com/api/v1.0/email/send',
      );

      Logger.info('📤 [RESET] Sending email via EmailJS...');

      // Prepare email data
      // Note: EmailJS templates may use different variable names
      // Common variables: to_email, to_name, user_email, reply_to
      final emailData = {
        'service_id': emailjsServiceId,
        'template_id': emailjsTemplateId,
        'user_id': emailjsUserId,
        'template_params': {
          'to_email': email, // Recipient email address
          'to_name': email
              .split('@')
              .first, // Recipient name (optional but recommended)
          'user_email': email, // Alternative variable name some templates use
          'user_name': email.split('@').first, // User name
          'reset_link': resetLink, // Password reset link
          'from_name': 'OPAD', // Sender name (optional)
        },
        'accessToken': emailjsPublicKey,
      };

      // Send email via EmailJS
      try {
        final response = await http.post(
          emailjsUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(emailData),
        );

        Logger.info('📬 [RESET] EmailJS response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          Logger.info('✅ [RESET] Email sent successfully!');
          // Save the time of successful request
          await _saveLastRequestTime();
          return token; // Return token for success
        } else {
          Logger.warning('❌ [RESET] EmailJS returned status ${response.statusCode}');
          // Parse error response
          try {
            final errorData = jsonDecode(response.body);
            final errorMessage =
                errorData['message'] ?? errorData['text'] ?? response.body;
            Logger.error('❌ [RESET] EmailJS error', errorMessage);
            throw Exception('EmailJS API error: $errorMessage');
          } catch (e) {
            if (e is Exception && e.toString().contains('EmailJS API error')) {
              rethrow;
            }
            Logger.error('❌ [RESET] Failed to parse error response', e);
            throw Exception(
              'Failed to send email. Status: ${response.statusCode}, Response: ${response.body}',
            );
          }
        }
      } catch (e) {
        Logger.error('❌ [RESET] EmailJS request failed', e);
        // Re-throw to be handled by caller
        rethrow;
      }
    } catch (e) {
      Logger.error('❌ [RESET] Error in sendPasswordResetEmail', e);
      return null;
    }
  }

  /// Get reset link for a given email and token
  String getResetLink(String email, String token) {
    return '${Uri.base.origin}/#/reset-password?email=${Uri.encodeComponent(email)}&token=$token';
  }

  /// Alternative: Send email using mailto link (fallback)
  /// This opens user's email client
  String getMailtoLink(String email, String token) {
    final resetLink = getResetLink(email, token);
    final subject = 'Відновлення пароля - OPAD';
    final body =
        '''
Шановний користувач,

Ви запросили відновлення пароля для вашого облікового запису.

Для відновлення пароля перейдіть за посиланням:
$resetLink

Якщо ви не запитували відновлення пароля, проігноруйте це повідомлення.

Посилання дійсне протягом 24 годин.

З повагою,
Команда OPAD
    ''';

    return 'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
  }

  /// Update password in MySQL database
  Future<bool> updatePassword(
    String email,
    String token,
    String newPassword,
  ) async {
    try {
      Logger.info('🔑 [UPDATE_PASSWORD] Starting password update');
      Logger.info('🔑 [UPDATE_PASSWORD] Email: $email');
      Logger.info('🔑 [UPDATE_PASSWORD] Token: ${token.substring(0, 8)}...');
      Logger.info('🔑 [UPDATE_PASSWORD] New password length: ${newPassword.length}');

      // Verify token first
      Logger.info('🔐 [UPDATE_PASSWORD] Verifying token...');
      final isValid = await verifyResetToken(email, token);
      Logger.info('🔐 [UPDATE_PASSWORD] Token valid: $isValid');

      if (!isValid) {
        Logger.warning('❌ [UPDATE_PASSWORD] Token verification failed');
        return false;
      }

      // Update password in MySQL database
      Logger.info('💾 [UPDATE_PASSWORD] Calling SQL service to update password');
      final success = await _sqlService.updatePassword(email, newPassword);

      Logger.info('💾 [UPDATE_PASSWORD] SQL service result: $success');

      if (success) {
        // Mark token as used
        Logger.info('🔄 [UPDATE_PASSWORD] Marking token as used');
        await _removeResetToken(email, token);
        Logger.info('✅ [UPDATE_PASSWORD] Password updated successfully');
        return true;
      }

      Logger.warning('❌ [UPDATE_PASSWORD] SQL service returned false');
      return false;
    } catch (e) {
      Logger.error('❌ [UPDATE_PASSWORD] Exception', e);
      return false;
    }
  }
}

/// Exception thrown when rate limit is exceeded
class RateLimitException implements Exception {
  final int secondsRemaining;

  RateLimitException(this.secondsRemaining);

  @override
  String toString() {
    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;
    if (minutes > 0) {
      return 'Rate limit exceeded. Please wait $minutes minute${minutes > 1 ? 's' : ''} and $seconds second${seconds != 1 ? 's' : ''}.';
    }
    return 'Rate limit exceeded. Please wait $seconds second${seconds != 1 ? 's' : ''}.';
  }

  String toLocalizedString() {
    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;
    if (minutes > 0) {
      return 'Занадто багато запитів. Будь ласка, зачекайте $minutes хвилин${minutes > 1 ? 'и' : 'у'} та $seconds секунд${seconds != 1 ? 'и' : 'у'}.';
    }
    return 'Занадто багато запитів. Будь ласка, зачекайте $seconds секунд${seconds != 1 ? 'и' : 'у'}.';
  }
}
