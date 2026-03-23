# Email Setup Guide - TheHost.com.ua

Complete step-by-step guide to configure professional email sending for OPAD application.

## Part 1: Create Professional Email Account on TheHost.com.ua

### Step 1.1: Access cPanel

1. Go to https://thehost.ua/en
2. Login to your control panel
3. Look for "cPanel" or "Hosting Control Panel"
4. Enter your hosting credentials

### Step 1.2: Create Email Account

1. In cPanel, find **"Email Accounts"** or **"Email"** section
2. Click **"Create"** or **"Add Email Account"**
3. Fill in the form:
   - **Email**: `noreply@opad.com.ua` (or `support@opad.com.ua`)
   - **Password**: Create a strong password (save this!)
   - **Mailbox**: 500 MB (or more)
4. Click **"Create Email Account"**

### Step 1.3: Get SMTP Credentials

1. Still in cPanel, find **"Email Accounts"** section
2. Look for your newly created email account
3. Click **"Configure Email Client"** or **"More Details"**
4. You'll see SMTP settings:
   - **SMTP Server**: `mail.opad.com.ua` or `s19.thehost.com.ua`
   - **SMTP Port**: `587` (TLS) or `465` (SSL)
   - **Username**: `noreply@opad.com.ua`
   - **Password**: The password you created
5. **Save these credentials** - you'll need them

### Step 1.4: Test Email Account

1. In cPanel, find **"Webmail"** or **"Roundcube"**
2. Login with your new email credentials
3. Send a test email to yourself
4. Verify it works

---

## Part 2: Configure Backend Email Service

### Step 2.1: Create Email Configuration File

Create `flutter-opad/backend/.env.example`:

```bash
# Email Configuration
SMTP_HOST=mail.opad.com.ua
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=noreply@opad.com.ua
SMTP_PASSWORD=your_email_password_here
SMTP_FROM_EMAIL=noreply@opad.com.ua
SMTP_FROM_NAME=OPAD - Одеська обласна профспілка авіадиспетчерів

# Database Configuration
DB_HOST=s19.thehost.com.ua
DB_USER=opad2016
DB_PASSWORD=opad2016
DB_NAME=opad

# Server Configuration
PORT=8000
NODE_ENV=production
```

### Step 2.2: Create Actual .env File

1. SSH into your server:
```bash
ssh username@opad.com.ua
```

2. Navigate to backend:
```bash
cd ~/public_html/api
```

3. Create `.env` file with your actual credentials:
```bash
cat > .env << 'EOF'
SMTP_HOST=mail.opad.com.ua
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=noreply@opad.com.ua
SMTP_PASSWORD=your_actual_password_here
SMTP_FROM_EMAIL=noreply@opad.com.ua
SMTP_FROM_NAME=OPAD - Одеська обласна профспілка авіадиспетчерів

DB_HOST=s19.thehost.com.ua
DB_USER=opad2016
DB_PASSWORD=opad2016
DB_NAME=opad

PORT=8000
NODE_ENV=production
EOF
```

4. Secure the file:
```bash
chmod 600 .env
```

### Step 2.3: Install PHPMailer (for PHP Backend)

Since your backend is in PHP, add PHPMailer via Composer:

1. SSH into server:
```bash
ssh username@opad.com.ua
cd ~/public_html/api
```

2. Install Composer (if not installed):
```bash
curl -sS https://getcomposer.org/installer | php
```

3. Create `composer.json`:
```bash
cat > composer.json << 'EOF'
{
    "require": {
        "phpmailer/phpmailer": "^6.8"
    }
}
EOF
```

4. Install dependencies:
```bash
php composer.phar install
```

---

## Part 3: Create Email Service in Backend

### Step 3.1: Create Email Configuration Class

Create `flutter-opad/backend/EmailConfig.php`:

```php
<?php
/**
 * Email Configuration
 * Loads SMTP settings from environment variables
 */

class EmailConfig {
    public static $host = 'mail.opad.com.ua';
    public static $port = 587;
    public static $secure = false;
    public static $username = 'noreply@opad.com.ua';
    public static $password = 'your_password';
    public static $fromEmail = 'noreply@opad.com.ua';
    public static $fromName = 'OPAD - Одеська обласна профспілка авіадиспетчерів';

    public static function loadFromEnv() {
        self::$host = getenv('SMTP_HOST') ?: self::$host;
        self::$port = (int)(getenv('SMTP_PORT') ?: self::$port);
        self::$secure = getenv('SMTP_SECURE') === 'true';
        self::$username = getenv('SMTP_USER') ?: self::$username;
        self::$password = getenv('SMTP_PASSWORD') ?: self::$password;
        self::$fromEmail = getenv('SMTP_FROM_EMAIL') ?: self::$fromEmail;
        self::$fromName = getenv('SMTP_FROM_NAME') ?: self::$fromName;
    }
}

// Load from environment on include
EmailConfig::loadFromEnv();
?>
```

### Step 3.2: Create Email Service Class

Create `flutter-opad/backend/EmailService.php`:

```php
<?php
/**
 * Email Service
 * Handles all email sending functionality
 */

require 'vendor/autoload.php';
require 'EmailConfig.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

class EmailService {
    private $mailer;

    public function __construct() {
        $this->mailer = new PHPMailer(true);
        $this->configureSMTP();
    }

    private function configureSMTP() {
        try {
            // SMTP configuration
            $this->mailer->isSMTP();
            $this->mailer->Host = EmailConfig::$host;
            $this->mailer->Port = EmailConfig::$port;
            $this->mailer->SMTPSecure = EmailConfig::$secure ? PHPMailer::ENCRYPTION_SMTPS : PHPMailer::ENCRYPTION_STARTTLS;
            $this->mailer->SMTPAuth = true;
            $this->mailer->Username = EmailConfig::$username;
            $this->mailer->Password = EmailConfig::$password;
            $this->mailer->CharSet = 'UTF-8';

            // From address
            $this->mailer->setFrom(EmailConfig::$fromEmail, EmailConfig::$fromName);
        } catch (Exception $e) {
            throw new Exception("SMTP Configuration Error: " . $e->getMessage());
        }
    }

    /**
     * Send password reset email
     */
    public function sendPasswordResetEmail($toEmail, $toName, $resetLink) {
        try {
            $this->mailer->addAddress($toEmail, $toName);
            $this->mailer->isHTML(true);
            $this->mailer->Subject = 'Скидання пароля - OPAD';

            $htmlBody = $this->getPasswordResetTemplate($toName, $resetLink);
            $this->mailer->Body = $htmlBody;
            $this->mailer->AltBody = strip_tags($htmlBody);

            $result = $this->mailer->send();
            $this->mailer->clearAddresses();
            return $result;
        } catch (Exception $e) {
            throw new Exception("Email Send Error: " . $e->getMessage());
        }
    }

    /**
     * Send welcome email
     */
    public function sendWelcomeEmail($toEmail, $toName) {
        try {
            $this->mailer->addAddress($toEmail, $toName);
            $this->mailer->isHTML(true);
            $this->mailer->Subject = 'Ласкаво просимо до OPAD';

            $htmlBody = $this->getWelcomeTemplate($toName);
            $this->mailer->Body = $htmlBody;
            $this->mailer->AltBody = strip_tags($htmlBody);

            $result = $this->mailer->send();
            $this->mailer->clearAddresses();
            return $result;
        } catch (Exception $e) {
            throw new Exception("Email Send Error: " . $e->getMessage());
        }
    }

    /**
     * Send notification email
     */
    public function sendNotificationEmail($toEmail, $toName, $subject, $message) {
        try {
            $this->mailer->addAddress($toEmail, $toName);
            $this->mailer->isHTML(true);
            $this->mailer->Subject = $subject;

            $htmlBody = $this->getNotificationTemplate($toName, $message);
            $this->mailer->Body = $htmlBody;
            $this->mailer->AltBody = strip_tags($htmlBody);

            $result = $this->mailer->send();
            $this->mailer->clearAddresses();
            return $result;
        } catch (Exception $e) {
            throw new Exception("Email Send Error: " . $e->getMessage());
        }
    }

    /**
     * Password reset email template
     */
    private function getPasswordResetTemplate($name, $resetLink) {
        return "
        <html>
        <head>
            <meta charset='UTF-8'>
            <style>
                body { font-family: Arial, sans-serif; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background-color: #0096D6; color: white; padding: 20px; text-align: center; border-radius: 5px; }
                .content { padding: 20px; background-color: #f9f9f9; margin-top: 20px; border-radius: 5px; }
                .button { display: inline-block; background-color: #0096D6; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; }
                .footer { text-align: center; color: #999; font-size: 12px; margin-top: 20px; }
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'>
                    <h1>OPAD - Одеська обласна профспілка авіадиспетчерів</h1>
                </div>
                <div class='content'>
                    <p>Привіт, <strong>$name</strong>!</p>
                    <p>Ви запросили скидання пароля для вашого облікового запису.</p>
                    <p>Натисніть на кнопку нижче, щоб встановити новий пароль:</p>
                    <a href='$resetLink' class='button'>Скинути пароль</a>
                    <p>Це посилання дійсне протягом 24 годин.</p>
                    <p>Якщо ви не запросили скидання пароля, проігноруйте цей лист.</p>
                </div>
                <div class='footer'>
                    <p>© 2024 OPAD. Всі права захищені.</p>
                    <p>Це автоматичне повідомлення, будь ласка, не відповідайте на нього.</p>
                </div>
            </div>
        </body>
        </html>
        ";
    }

    /**
     * Welcome email template
     */
    private function getWelcomeTemplate($name) {
        return "
        <html>
        <head>
            <meta charset='UTF-8'>
            <style>
                body { font-family: Arial, sans-serif; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background-color: #0096D6; color: white; padding: 20px; text-align: center; border-radius: 5px; }
                .content { padding: 20px; background-color: #f9f9f9; margin-top: 20px; border-radius: 5px; }
                .footer { text-align: center; color: #999; font-size: 12px; margin-top: 20px; }
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'>
                    <h1>OPAD - Одеська обласна профспілка авіадиспетчерів</h1>
                </div>
                <div class='content'>
                    <p>Ласкаво просимо, <strong>$name</strong>!</p>
                    <p>Ваш обліковий запис успішно створено.</p>
                    <p>Тепер ви можете отримувати доступ до всіх послуг OPAD.</p>
                </div>
                <div class='footer'>
                    <p>© 2024 OPAD. Всі права захищені.</p>
                </div>
            </div>
        </body>
        </html>
        ";
    }

    /**
     * Notification email template
     */
    private function getNotificationTemplate($name, $message) {
        return "
        <html>
        <head>
            <meta charset='UTF-8'>
            <style>
                body { font-family: Arial, sans-serif; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background-color: #0096D6; color: white; padding: 20px; text-align: center; border-radius: 5px; }
                .content { padding: 20px; background-color: #f9f9f9; margin-top: 20px; border-radius: 5px; }
                .footer { text-align: center; color: #999; font-size: 12px; margin-top: 20px; }
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'>
                    <h1>OPAD - Одеська обласна профспілка авіадиспетчерів</h1>
                </div>
                <div class='content'>
                    <p>Привіт, <strong>$name</strong>!</p>
                    <p>$message</p>
                </div>
                <div class='footer'>
                    <p>© 2024 OPAD. Всі права захищені.</p>
                </div>
            </div>
        </body>
        </html>
        ";
    }
}
?>
```

### Step 3.3: Add Email Endpoint to API

Update `flutter-opad/backend/api.php` to include email sending:

Add this after the database connection section:

```php
// 2.5. Load Email Service
require_once 'EmailService.php';
$emailService = new EmailService();
```

Add this new endpoint in the switch statement:

```php
    // Send Password Reset Email
    case ($route === 'email/send-reset' && $method === 'POST'):
        $body = get_json_body();
        $email = isset($body['email']) ? $body['email'] : null;
        $name = isset($body['name']) ? $body['name'] : 'User';
        $resetLink = isset($body['resetLink']) ? $body['resetLink'] : null;

        if (!$email || !$resetLink) {
            http_response_code(400);
            echo json_encode(["error" => "Email and resetLink are required"]);
            break;
        }

        try {
            $emailService->sendPasswordResetEmail($email, $name, $resetLink);
            echo json_encode(["success" => true, "message" => "Email sent successfully"]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["error" => "Failed to send email: " . $e->getMessage()]);
        }
        break;

    // Send Welcome Email
    case ($route === 'email/send-welcome' && $method === 'POST'):
        $body = get_json_body();
        $email = isset($body['email']) ? $body['email'] : null;
        $name = isset($body['name']) ? $body['name'] : 'User';

        if (!$email) {
            http_response_code(400);
            echo json_encode(["error" => "Email is required"]);
            break;
        }

        try {
            $emailService->sendWelcomeEmail($email, $name);
            echo json_encode(["success" => true, "message" => "Welcome email sent"]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["error" => "Failed to send email: " . $e->getMessage()]);
        }
        break;

    // Send Notification Email
    case ($route === 'email/send-notification' && $method === 'POST'):
        $body = get_json_body();
        $email = isset($body['email']) ? $body['email'] : null;
        $name = isset($body['name']) ? $body['name'] : 'User';
        $subject = isset($body['subject']) ? $body['subject'] : 'Notification';
        $message = isset($body['message']) ? $body['message'] : '';

        if (!$email || !$message) {
            http_response_code(400);
            echo json_encode(["error" => "Email and message are required"]);
            break;
        }

        try {
            $emailService->sendNotificationEmail($email, $name, $subject, $message);
            echo json_encode(["success" => true, "message" => "Notification sent"]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["error" => "Failed to send email: " . $e->getMessage()]);
        }
        break;
```

---

## Part 4: Add Email Service to Flutter App

### Step 4.1: Create Email Service in Flutter

Create `flutter-opad/lib/services/email_service.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_opad/utils/k.dart';
import '../utils/logger.dart';

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
        data: {
          'email': email,
          'name': name,
          'resetLink': resetLink,
        },
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
        data: {
          'email': email,
          'name': name,
        },
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
```

### Step 4.2: Add Email Service to K.dart

Update `flutter-opad/lib/utils/k.dart`:

```dart
  /// Access global singleton services
  static SqlService get sqlService => SqlService();
  static AuthService get authService => AuthService();
  static ApiService get apiService => ApiService();
  static EmailService get emailService => EmailService();
```

### Step 4.3: Use Email Service in Your App

Example in password reset logic:

```dart
// Send password reset email
final success = await K.emailService.sendPasswordResetEmail(
  email: userEmail,
  name: userName,
  resetLink: 'https://opad.com.ua/reset?token=abc123',
);

if (success) {
  K.showSnackBar('Email sent successfully');
} else {
  K.showSnackBar('Failed to send email', isError: true);
}
```

---

## Part 5: Test Email Configuration

### Step 5.1: Test SMTP Connection

SSH into server and test:

```bash
ssh username@opad.com.ua
cd ~/public_html/api

# Create test script
cat > test_email.php << 'EOF'
<?php
require 'vendor/autoload.php';
require 'EmailConfig.php';
require 'EmailService.php';

try {
    $emailService = new EmailService();
    $result = $emailService->sendWelcomeEmail(
        'your_email@example.com',
        'Test User'
    );
    echo "Email sent: " . ($result ? "SUCCESS" : "FAILED");
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>
EOF

# Run test
php test_email.php
```

### Step 5.2: Test API Endpoint

```bash
curl -X POST https://opad.com.ua/api/email/send-welcome \
  -H "Content-Type: application/json" \
  -d '{
    "email": "your_email@example.com",
    "name": "Test User"
  }'
```

### Step 5.3: Check Email Logs

```bash
# View PHP errors
tail -f /var/log/php-errors.log

# Check mail logs
tail -f /var/log/mail.log
```

---

## Part 6: Deployment Checklist

- [ ] Created professional email account on TheHost (noreply@opad.com.ua)
- [ ] Got SMTP credentials from cPanel
- [ ] Created `.env` file with SMTP settings
- [ ] Installed Composer and PHPMailer
- [ ] Created EmailConfig.php
- [ ] Created EmailService.php
- [ ] Updated api.php with email endpoints
- [ ] Created Flutter EmailService
- [ ] Added EmailService to K.dart
- [ ] Tested SMTP connection
- [ ] Tested API endpoints
- [ ] Tested email delivery
- [ ] Updated password reset flow to send emails
- [ ] Updated user registration to send welcome emails

---

## Part 7: Troubleshooting

### Email Not Sending

1. **Check SMTP credentials**
   ```bash
   cat ~/public_html/api/.env | grep SMTP
   ```

2. **Check PHP errors**
   ```bash
   tail -f /var/log/php-errors.log
   ```

3. **Test connection manually**
   ```bash
   telnet mail.opad.com.ua 587
   ```

4. **Check firewall**
   - Ensure port 587 is open
   - Contact TheHost support if blocked

### Emails Going to Spam

1. **Add SPF record** in DNS:
   ```
   v=spf1 include:thehost.com.ua ~all
   ```

2. **Add DKIM** in cPanel:
   - Go to Email Authentication
   - Enable DKIM for your domain

3. **Add DMARC** in DNS:
   ```
   v=DMARC1; p=none; rua=mailto:admin@opad.com.ua
   ```

### Connection Timeout

1. Check if SMTP port is correct (587 or 465)
2. Verify firewall allows outgoing connections
3. Contact TheHost support

---

## Security Best Practices

✅ **Do:**
- Store SMTP password in `.env` file
- Never commit `.env` to git
- Use strong email account password
- Enable 2FA on email account
- Monitor email logs
- Use HTTPS for all email links

❌ **Don't:**
- Hardcode passwords in code
- Send sensitive data in emails
- Use personal email accounts
- Ignore email delivery failures
- Skip SPF/DKIM/DMARC setup

---

## Next Steps

1. Create email account on TheHost
2. Get SMTP credentials
3. Deploy EmailConfig.php and EmailService.php
4. Update api.php with endpoints
5. Test email sending
6. Integrate with Flutter app
7. Monitor email delivery
8. Set up SPF/DKIM/DMARC records

Good luck! 🚀
