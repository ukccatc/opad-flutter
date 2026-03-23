# Flutter Email Integration Guide

Complete guide for using email functionality in the Flutter app.

## Files Created

### Configuration
- `lib/config/email_config.dart` - Email settings and utilities
- `lib/models/m_email_response.dart` - Email API response model

### Services
- `lib/services/email_service.dart` - Low-level email API calls

### Logic
- `lib/logic/l_email.dart` - Email business logic with state management

### Widgets
- `lib/widgets/email_status_widget.dart` - Email status display
- `lib/widgets/password_reset_dialog.dart` - Password reset dialog

### Updated Files
- `lib/main.dart` - Added EmailLogic provider
- `lib/utils/k.dart` - Added emailService getter

---

## Usage Examples

### 1. Send Password Reset Email

```dart
import 'package:flutter_opad/logic/l_email.dart';
import 'package:flutter_opad/utils/k.dart';

// In your widget
final emailLogic = context.read<EmailLogic>();

final success = await emailLogic.sendPasswordResetEmail(
  email: 'user@example.com',
  name: 'John Doe',
  token: 'reset_token_123',
);

if (success) {
  K.showSnackBar('Password reset email sent');
} else {
  K.showSnackBar(emailLogic.lastError ?? 'Failed to send email', isError: true);
}
```

### 2. Send Welcome Email

```dart
final emailLogic = context.read<EmailLogic>();

final success = await emailLogic.sendWelcomeEmail(
  email: 'newuser@example.com',
  name: 'Jane Smith',
);

if (success) {
  K.showSnackBar('Welcome email sent');
}
```

### 3. Send Notification Email

```dart
final emailLogic = context.read<EmailLogic>();

final success = await emailLogic.sendNotificationEmail(
  email: 'user@example.com',
  name: 'John Doe',
  subject: 'Important Update',
  message: 'Your account has been updated.',
);
```

### 4. Use Password Reset Dialog

```dart
import 'package:flutter_opad/widgets/password_reset_dialog.dart';

// Show dialog
showDialog(
  context: context,
  builder: (context) => PasswordResetDialog(
    initialEmail: 'user@example.com',
    onSuccess: () {
      // Handle success
      Navigator.of(context).pop();
    },
  ),
);
```

### 5. Display Email Status

```dart
import 'package:flutter_opad/widgets/email_status_widget.dart';

// In your widget tree
Column(
  children: [
    EmailStatusWidget(
      onDismiss: () {
        // Handle dismiss
      },
    ),
    // Other widgets
  ],
)
```

### 6. Access Email Service Directly

```dart
import 'package:flutter_opad/utils/k.dart';

// Send email directly
final success = await K.emailService.sendWelcomeEmail(
  email: 'user@example.com',
  name: 'User Name',
);
```

---

## Email Configuration

Edit `lib/config/email_config.dart` to customize:

```dart
// Email addresses
static const String supportEmail = 'noreply@opad.com.ua';
static const String supportName = 'OPAD - Одеська обласна профспілка авіадиспетчерів';

// Email subjects
static const String passwordResetSubject = 'Скидання пароля - OPAD';
static const String welcomeSubject = 'Ласкаво просимо до OPAD';

// Reset link configuration
static const String resetLinkBase = 'https://opad.com.ua/reset';
static const int resetLinkExpiryHours = 24;
```

---

## Email Validation

```dart
import 'package:flutter_opad/config/email_config.dart';

// Validate email
if (EmailConfig.isValidEmail('user@example.com')) {
  print('Valid email');
} else {
  print('Invalid email');
}

// Generate reset link
final resetLink = EmailConfig.generateResetLink('token_123');
// Output: https://opad.com.ua/reset?token=token_123
```

---

## State Management

### EmailLogic Properties

```dart
// Check if email is being sent
if (emailLogic.isSending) {
  print('Email is being sent...');
}

// Get last error
if (emailLogic.lastError != null) {
  print('Error: ${emailLogic.lastError}');
}

// Get last response
if (emailLogic.lastResponse != null) {
  print('Message: ${emailLogic.lastResponse!.message}');
}

// Check if last operation was successful
if (emailLogic.lastOperationSuccess) {
  print('Email sent successfully');
}
```

### Clear State

```dart
// Clear error
emailLogic.clearError();

// Clear response
emailLogic.clearResponse();
```

---

## Integration with Login Screen

Example of integrating password reset with login:

```dart
import 'package:flutter_opad/widgets/password_reset_dialog.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Login form
          TextField(
            // email field
          ),
          TextField(
            // password field
          ),
          ElevatedButton(
            onPressed: () {
              // Login logic
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => PasswordResetDialog(
                  onSuccess: () {
                    K.showSnackBar('Check your email for reset link');
                  },
                ),
              );
            },
            child: const Text('Forgot Password?'),
          ),
        ],
      ),
    );
  }
}
```

---

## Integration with Registration

Example of sending welcome email on registration:

```dart
import 'package:flutter_opad/logic/l_email.dart';

class RegistrationLogic extends ChangeNotifier {
  final EmailLogic _emailLogic = EmailLogic();

  Future<bool> registerUser({
    required String email,
    required String name,
    required String password,
  }) async {
    try {
      // Register user in database
      // ... registration code ...

      // Send welcome email
      await _emailLogic.sendWelcomeEmail(
        email: email,
        name: name,
      );

      return true;
    } catch (e) {
      Logger.error('Registration error', e);
      return false;
    }
  }
}
```

---

## Error Handling

```dart
final emailLogic = context.read<EmailLogic>();

try {
  final success = await emailLogic.sendPasswordResetEmail(
    email: email,
    name: name,
    token: token,
  );

  if (!success) {
    // Handle email send failure
    final error = emailLogic.lastError;
    K.showSnackBar(error ?? 'Failed to send email', isError: true);
  }
} catch (e) {
  // Handle exception
  K.showSnackBar('Error: $e', isError: true);
}
```

---

## Testing Email Functionality

### Test Password Reset

```dart
// In your test file
testWidgets('Send password reset email', (WidgetTester tester) async {
  final emailLogic = EmailLogic();

  final success = await emailLogic.sendPasswordResetEmail(
    email: 'test@example.com',
    name: 'Test User',
    token: 'test_token',
  );

  expect(success, true);
  expect(emailLogic.lastOperationSuccess, true);
});
```

### Test Email Validation

```dart
testWidgets('Validate email addresses', (WidgetTester tester) async {
  expect(EmailConfig.isValidEmail('valid@example.com'), true);
  expect(EmailConfig.isValidEmail('invalid.email'), false);
  expect(EmailConfig.isValidEmail(''), false);
});
```

---

## Logging

All email operations are logged with emoji indicators:

```
📧 [EMAIL] Sending password reset email to: user@example.com
✅ [EMAIL] Password reset email sent
❌ [EMAIL] Failed to send password reset email
```

Check the logger output to debug email issues.

---

## Best Practices

1. **Always validate email** before sending
   ```dart
   if (!EmailConfig.isValidEmail(email)) {
     K.showSnackBar('Invalid email address', isError: true);
     return;
   }
   ```

2. **Show loading state** while sending
   ```dart
   if (emailLogic.isSending) {
     return const CircularProgressIndicator();
   }
   ```

3. **Handle errors gracefully**
   ```dart
   if (emailLogic.lastError != null) {
     K.showSnackBar(emailLogic.lastError!, isError: true);
   }
   ```

4. **Clear state after use**
   ```dart
   emailLogic.clearError();
   emailLogic.clearResponse();
   ```

5. **Use EmailStatusWidget** for consistent UI
   ```dart
   EmailStatusWidget(
     onDismiss: () {
       // Handle dismiss
     },
   )
   ```

---

## Troubleshooting

### Email not sending
- Check backend is running
- Verify SMTP credentials in `.env`
- Check network connectivity
- Review logs for errors

### Invalid email error
- Ensure email format is correct
- Use `EmailConfig.isValidEmail()` to validate

### Timeout errors
- Check backend API is responding
- Verify network connectivity
- Increase timeout in `EmailService`

### CORS errors
- Verify backend CORS configuration
- Check API URL is correct

---

## Next Steps

1. Integrate password reset with login screen
2. Integrate welcome email with registration
3. Add email notifications for important events
4. Set up email templates for different scenarios
5. Monitor email delivery and failures
6. Add email preferences to user settings

Good luck! 🚀
