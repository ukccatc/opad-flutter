# Password Reset Setup Guide

## Overview

The password reset functionality uses EmailJS to send password reset emails without requiring a backend server. Users can request a password reset, receive an email with a reset link, and then set a new password.

## How It Works

1. **User requests password reset** (`/forgot-password`)
   - Enters their email address
   - System checks if email exists in local database
   - Generates a secure reset token (SHA-256 hash)
   - Saves token with 24-hour expiration

2. **Email sent with reset link**
   - EmailJS sends email to user
   - Email contains link: `/reset-password?email=...&token=...`

3. **User clicks link and resets password** (`/reset-password`)
   - Token is verified (validity and expiration)
   - User enters new password
   - Password is hashed with MD5 and updated in local database
   - Token is removed after successful reset

## EmailJS Setup

### Step 1: Create EmailJS Account

1. Go to https://www.emailjs.com/
2. Sign up for a free account (200 emails/month free)
3. Verify your email address

### Step 2: Add Email Service

1. Go to **Email Services** in dashboard
2. Click **Add New Service**
3. Choose your email provider (Gmail, Outlook, etc.)
4. Follow the setup instructions
5. Copy your **Service ID**

### Step 3: Create Email Template

1. Go to **Email Templates**
2. Click **Create New Template**
3. Use this template:

```
Subject: Відновлення пароля - OPAD

Шановний {{user_name}},

Ви запросили відновлення пароля для вашого облікового запису в системі OPAD.

Для встановлення нового пароля перейдіть за посиланням:
{{reset_link}}

Якщо ви не запитували відновлення пароля, проігноруйте це повідомлення.

Посилання дійсне протягом 24 годин.

З повагою,
Команда OPAD
```

4. Copy your **Template ID**

### Step 4: Get Public Key

1. Go to **Account** → **General**
2. Copy your **Public Key** (User ID)

### Step 5: Configure in Code

Update `lib/services/password_reset_service.dart`:

```dart
const emailjsServiceId = 'YOUR_SERVICE_ID';      // From Step 2
const emailjsTemplateId = 'YOUR_TEMPLATE_ID';    // From Step 3
const emailjsPublicKey = 'YOUR_PUBLIC_KEY';      // From Step 4
const emailjsUserId = 'YOUR_USER_ID';            // From Step 4 (same as Public Key)
```

## Alternative: WordPress Email API

If you have WordPress backend access, you can create a custom endpoint:

```php
// In WordPress functions.php or custom plugin
add_action('rest_api_init', function () {
    register_rest_route('opad/v1', '/password-reset', array(
        'methods' => 'POST',
        'callback' => 'opad_send_password_reset_email',
        'permission_callback' => '__return_true',
    ));
});

function opad_send_password_reset_email($request) {
    $email = $request->get_param('email');
    $reset_link = $request->get_param('reset_link');
    
    // Use WordPress wp_mail() function
    $subject = 'Відновлення пароля - OPAD';
    $message = "Перейдіть за посиланням для відновлення пароля:\n\n$reset_link";
    
    $sent = wp_mail($email, $subject, $message);
    
    return array('success' => $sent);
}
```

Then update `password_reset_service.dart` to use WordPress API instead of EmailJS.

## Development Mode

In development, if EmailJS is not configured, the system will:
- Still generate and save reset tokens
- Print reset link to console
- Show reset link on screen (for testing)
- Allow password reset to work

## Security Notes

1. **Token Expiration**: Tokens expire after 24 hours
2. **Token Storage**: Tokens stored locally in SharedPreferences (for development)
3. **Password Hashing**: Passwords hashed with MD5 (matches existing system)
4. **Token Removal**: Tokens are removed after successful password reset

## Testing

1. Go to `/forgot-password`
2. Enter a valid email from your database
3. Check console/logs for reset link (if EmailJS not configured)
4. Copy reset link and open in browser
5. Enter new password
6. Try logging in with new password

## Production Considerations

1. **EmailJS Limits**: Free plan allows 200 emails/month
2. **Token Storage**: Consider storing tokens in database instead of SharedPreferences
3. **Password Policy**: Consider adding password strength requirements
4. **Rate Limiting**: Add rate limiting to prevent abuse
5. **Email Delivery**: Monitor email delivery rates

