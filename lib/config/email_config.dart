/// Email Configuration
/// Centralized email settings for the application
class EmailConfig {
  // Email addresses
  static const String supportEmail = 'noreply@opad.com.ua';
  static const String supportName =
      'OPAD - Одеська обласна профспілка авіадиспетчерів';

  // Email templates
  static const String passwordResetSubject = 'Скидання пароля - OPAD';
  static const String welcomeSubject = 'Ласкаво просимо до OPAD';

  // Reset link configuration
  static const String resetLinkBase = 'https://opad.com.ua/reset';
  static const int resetLinkExpiryHours = 24;

  // Email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Generate password reset link
  static String generateResetLink(String token) {
    return '$resetLinkBase?token=$token';
  }
}
