import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../data/users_data.dart';

/// Service for password reset functionality
/// Handles token generation, email sending, and password updates
class PasswordResetService {
  static const String _resetTokensKey = 'password_reset_tokens';
  static const String _lastRequestTimeKey = 'password_reset_last_request';
  static const int _tokenExpirationHours = 24; // Token valid for 24 hours
  static const int _rateLimitMinutes = 1; // Rate limit: 1 request per minute

  /// Generate a secure reset token
  String _generateResetToken(String email) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = '$email$timestamp';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Normalize email (lowercase for consistent comparison)
  String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Save reset token with expiration
  Future<void> _saveResetToken(String email, String token) async {
    final normalizedEmail = _normalizeEmail(email);
    final prefs = await SharedPreferences.getInstance();
    final tokensJson = prefs.getString(_resetTokensKey) ?? '{}';
    final tokens = Map<String, dynamic>.from(jsonDecode(tokensJson));

    tokens[normalizedEmail] = {
      'token': token,
      'expiresAt': DateTime.now()
          .add(Duration(hours: _tokenExpirationHours))
          .toIso8601String(),
    };

    await prefs.setString(_resetTokensKey, jsonEncode(tokens));
    print('Saved reset token for email: $normalizedEmail');
  }

  /// Verify reset token
  Future<bool> verifyResetToken(String email, String token) async {
    final normalizedEmail = _normalizeEmail(email);
    print('=== Verifying Reset Token ===');
    print('Original email: $email');
    print('Normalized email: $normalizedEmail');
    print('Token: $token');

    final prefs = await SharedPreferences.getInstance();
    final tokensJson = prefs.getString(_resetTokensKey) ?? '{}';
    final tokens = Map<String, dynamic>.from(jsonDecode(tokensJson));

    print('Stored tokens keys: ${tokens.keys.toList()}');

    if (!tokens.containsKey(normalizedEmail)) {
      print('Email not found in tokens');
      return false;
    }

    final tokenData = tokens[normalizedEmail] as Map<String, dynamic>;
    final storedToken = tokenData['token'] as String?;
    final expiresAt = DateTime.parse(tokenData['expiresAt'] as String);

    print('Stored token: $storedToken');
    print('Provided token: $token');
    print('Tokens match: ${storedToken == token}');
    print('Expires at: $expiresAt');
    print('Current time: ${DateTime.now()}');
    print('Is expired: ${DateTime.now().isAfter(expiresAt)}');

    if (storedToken != token || DateTime.now().isAfter(expiresAt)) {
      print('Token verification failed');
      return false;
    }

    print('Token verified successfully!');
    return true;
  }

  /// Remove used token
  Future<void> _removeResetToken(String email) async {
    final normalizedEmail = _normalizeEmail(email);
    final prefs = await SharedPreferences.getInstance();
    final tokensJson = prefs.getString(_resetTokensKey) ?? '{}';
    final tokens = Map<String, dynamic>.from(jsonDecode(tokensJson));

    tokens.remove(normalizedEmail);
    await prefs.setString(_resetTokensKey, jsonEncode(tokens));
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
      // Check rate limit
      final secondsRemaining = await checkRateLimit();
      if (secondsRemaining != null) {
        throw RateLimitException(secondsRemaining);
      }

      // Check if email exists in database
      final userData = UsersData.findByEmail(email);
      if (userData == null) {
        return null; // Email not found
      }

      // Generate reset token
      final token = _generateResetToken(email);
      await _saveResetToken(email, token);

      // Create reset link
      // For web, we'll use the current origin
      final resetLink = getResetLink(email, token);

      // EmailJS configuration
      const emailjsServiceId = 'service_c93pzgc';
      const emailjsTemplateId = 'template_sjl6ihm';
      const emailjsPublicKey = 'EBROESqvv299ugyQS';
      const emailjsUserId = 'EBROESqvv299ugyQS';

      // EmailJS API endpoint
      final emailjsUrl = Uri.parse(
        'https://api.emailjs.com/api/v1.0/email/send',
      );

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
        print('=== EmailJS Request ===');
        print('URL: $emailjsUrl');
        print('Service ID: $emailjsServiceId');
        print('Template ID: $emailjsTemplateId');
        print('User ID: $emailjsUserId');
        print('Public Key: $emailjsPublicKey');
        print('To Email: $email');
        print('Reset Link: $resetLink');
        print('Request Body: ${jsonEncode(emailData)}');
        print('=====================');

        final response = await http.post(
          emailjsUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(emailData),
        );

        print('=== EmailJS Response ===');
        print('Status Code: ${response.statusCode}');
        print('Response Headers: ${response.headers}');
        print('Response Body: ${response.body}');
        print('======================');

        if (response.statusCode == 200) {
          print('✅ Email sent successfully!');
          // Save the time of successful request
          await _saveLastRequestTime();
          return token; // Return token for success
        } else {
          // Parse error response
          try {
            final errorData = jsonDecode(response.body);
            print('❌ EmailJS API Error: ${errorData.toString()}');
            final errorMessage =
                errorData['message'] ?? errorData['text'] ?? response.body;
            throw Exception('EmailJS API error: $errorMessage');
          } catch (e) {
            if (e is Exception && e.toString().contains('EmailJS API error')) {
              rethrow;
            }
            print(
              '❌ EmailJS Error (status ${response.statusCode}): ${response.body}',
            );
            throw Exception(
              'Failed to send email. Status: ${response.statusCode}, Response: ${response.body}',
            );
          }
        }
      } catch (e, stackTrace) {
        print('❌ EmailJS Exception: $e');
        print('Stack Trace: $stackTrace');
        // Re-throw to be handled by caller
        rethrow;
      }
    } catch (e) {
      print('Error sending password reset email: $e');
      return null;
    }
  }

  /// Get reset link for a given email and token
  String getResetLink(String email, String token) {
    return '${Uri.base.origin}/reset-password?email=${Uri.encodeComponent(email)}&token=$token';
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

  /// Update password in local database
  Future<bool> updatePassword(
    String email,
    String token,
    String newPassword,
  ) async {
    try {
      // Verify token first
      final isValid = await verifyResetToken(email, token);
      if (!isValid) {
        return false;
      }

      final userData = UsersData.findByEmail(email);
      if (userData == null) {
        return false;
      }

      // Hash new password with MD5
      final passwordHash = _md5Hash(newPassword);

      // Update password in local data
      // Note: In a real app, this should update the database
      // For now, we'll update the in-memory data structure
      final userIndex = UsersData.users.indexWhere(
        (user) => user['Email'].toString().toLowerCase() == email.toLowerCase(),
      );

      if (userIndex != -1) {
        UsersData.users[userIndex]['Password'] = passwordHash;
        // Remove used token
        await _removeResetToken(email);
        return true;
      }

      return false;
    } catch (e) {
      print('Error updating password: $e');
      return false;
    }
  }

  /// MD5 hash function
  String _md5Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = md5.convert(bytes);
    return digest.toString();
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
