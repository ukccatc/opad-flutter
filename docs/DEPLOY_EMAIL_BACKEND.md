# Deploy Email Backend to TheHost.com.ua

Complete deployment instructions for email functionality.

## Prerequisites

- SSH access to your TheHost.com.ua server
- cPanel access to create email account
- Your domain: opad.com.ua

---

## Step 1: Create Professional Email Account

### 1.1 Access cPanel

1. Go to https://thehost.ua/en
2. Login to your control panel
3. Click "cPanel" or "Hosting Control Panel"

### 1.2 Create Email Account

1. In cPanel, find **"Email Accounts"** section
2. Click **"Create"** or **"Add Email Account"**
3. Fill in:
   - **Email**: `noreply@opad.com.ua`
   - **Password**: Create a strong password (save this!)
   - **Mailbox**: 500 MB
4. Click **"Create Email Account"**

### 1.3 Get SMTP Credentials

1. In cPanel, find **"Email Accounts"** section
2. Click on your email account
3. Click **"Configure Email Client"** or **"More Details"**
4. Note these settings:
   - **SMTP Server**: `mail.opad.com.ua` (or `s19.thehost.com.ua`)
   - **SMTP Port**: `587` (TLS)
   - **Username**: `noreply@opad.com.ua`
   - **Password**: Your email password

---

## Step 2: Deploy Backend Files via SSH

### 2.1 Connect to Server

```bash
ssh username@opad.com.ua
```

Replace `username` with your actual username.

### 2.2 Navigate to Backend Directory

```bash
cd ~/public_html/api
```

### 2.3 Upload Backend Files

From your local machine, upload the files:

```bash
# From your local flutter-opad directory
scp backend/EmailConfig.php username@opad.com.ua:~/public_html/api/
scp backend/EmailService.php username@opad.com.ua:~/public_html/api/
scp backend/composer.json username@opad.com.ua:~/public_html/api/
scp backend/.env.example username@opad.com.ua:~/public_html/api/
```

Or use FTP to upload these files to `public_html/api/`

### 2.4 Create .env File

SSH into server:

```bash
ssh username@opad.com.ua
cd ~/public_html/api
```

Create `.env` file with your SMTP credentials:

```bash
cat > .env << 'EOF'
SMTP_HOST=mail.opad.com.ua
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=noreply@opad.com.ua
SMTP_PASSWORD=your_actual_email_password_here
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

**Important**: Replace `your_actual_email_password_here` with the password you created for noreply@opad.com.ua

### 2.5 Secure .env File

```bash
chmod 600 .env
```

---

## Step 3: Install Composer and PHPMailer

### 3.1 Check if Composer is Installed

```bash
which composer
```

If not found, install it:

```bash
cd ~/public_html/api
curl -sS https://getcomposer.org/installer | php
```

### 3.2 Install PHPMailer

```bash
cd ~/public_html/api

# If composer is installed globally
composer install

# If composer is local
php composer.phar install
```

This will create a `vendor/` directory with PHPMailer.

### 3.3 Verify Installation

```bash
ls -la vendor/phpmailer/phpmailer/
```

You should see the PHPMailer files.

---

## Step 4: Update api.php

### 4.1 Upload Updated api.php

From your local machine:

```bash
scp backend/api.php username@opad.com.ua:~/public_html/api/
```

Or manually update the file via FTP/cPanel File Manager.

The updated `api.php` includes:
- Email service initialization
- Three new email endpoints:
  - `POST /email/send-reset` - Send password reset email
  - `POST /email/send-welcome` - Send welcome email
  - `POST /email/send-notification` - Send notification email

---

## Step 5: Test Email Configuration

### 5.1 Test SMTP Connection

SSH into server:

```bash
ssh username@opad.com.ua
cd ~/public_html/api
```

Create test script:

```bash
cat > test_email.php << 'EOF'
<?php
require 'vendor/autoload.php';
require 'EmailConfig.php';
require 'EmailService.php';

try {
    $emailService = new EmailService();
    echo "✅ Email service initialized successfully\n";
    
    // Test sending welcome email
    $result = $emailService->sendWelcomeEmail(
        'your_email@example.com',
        'Test User'
    );
    
    if ($result) {
        echo "✅ Test email sent successfully\n";
    } else {
        echo "❌ Failed to send test email\n";
    }
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
EOF
```

Run test:

```bash
php test_email.php
```

### 5.2 Test API Endpoint

```bash
curl -X POST https://opad.com.ua/api/email/send-welcome \
  -H "Content-Type: application/json" \
  -d '{
    "email": "your_email@example.com",
    "name": "Test User"
  }'
```

Expected response:

```json
{
  "success": true,
  "message": "Welcome email sent"
}
```

### 5.3 Check Email Logs

```bash
# View PHP errors
tail -f /var/log/php-errors.log

# Check mail logs
tail -f /var/log/mail.log
```

---

## Step 6: Verify File Permissions

```bash
ssh username@opad.com.ua
cd ~/public_html/api

# Check permissions
ls -la

# Should see:
# -rw-r--r-- EmailConfig.php
# -rw-r--r-- EmailService.php
# -rw------- .env (600 permissions)
# -rw-r--r-- api.php
# drwxr-xr-x vendor/
```

---

## Step 7: Monitor Email Delivery

### 7.1 Check Email Logs

```bash
# View recent emails sent
tail -50 /var/log/mail.log | grep noreply@opad.com.ua
```

### 7.2 Test Email Delivery

Send a test email to yourself:

```bash
curl -X POST https://opad.com.ua/api/email/send-reset \
  -H "Content-Type: application/json" \
  -d '{
    "email": "your_email@example.com",
    "name": "Your Name",
    "resetLink": "https://opad.com.ua/reset?token=test123"
  }'
```

Check your email inbox for the message.

---

## Troubleshooting

### Email Service Not Available

**Error**: `"error": "Email service not available"`

**Solution**:
1. Check if `vendor/autoload.php` exists
2. Run `composer install` again
3. Check file permissions

### SMTP Connection Failed

**Error**: `SMTP Connection Error`

**Solution**:
1. Verify SMTP credentials in `.env`
2. Check if port 587 is open
3. Test connection:
   ```bash
   telnet mail.opad.com.ua 587
   ```

### Email Not Sending

**Error**: `Failed to send email`

**Solution**:
1. Check `.env` file has correct credentials
2. Verify email account exists in cPanel
3. Check PHP error logs:
   ```bash
   tail -f /var/log/php-errors.log
   ```

### Composer Not Found

**Error**: `composer: command not found`

**Solution**:
```bash
cd ~/public_html/api
curl -sS https://getcomposer.org/installer | php
php composer.phar install
```

### Permission Denied

**Error**: `Permission denied` when accessing `.env`

**Solution**:
```bash
chmod 600 .env
chmod 755 EmailConfig.php
chmod 755 EmailService.php
```

---

## Deployment Checklist

- [ ] Created email account `noreply@opad.com.ua` in cPanel
- [ ] Got SMTP credentials from cPanel
- [ ] Uploaded EmailConfig.php to server
- [ ] Uploaded EmailService.php to server
- [ ] Uploaded composer.json to server
- [ ] Created .env file with SMTP credentials
- [ ] Secured .env file (chmod 600)
- [ ] Installed Composer
- [ ] Ran `composer install`
- [ ] Verified vendor/phpmailer/ exists
- [ ] Uploaded updated api.php
- [ ] Tested SMTP connection
- [ ] Tested API endpoints
- [ ] Verified email delivery
- [ ] Checked logs for errors
- [ ] Monitored email sending

---

## File Structure on Server

After deployment, your `~/public_html/api/` should look like:

```
api/
├── api.php                    (updated with email endpoints)
├── EmailConfig.php            (new)
├── EmailService.php           (new)
├── composer.json              (new)
├── composer.lock              (auto-generated)
├── .env                       (new - keep secure!)
├── .env.example               (reference)
├── vendor/                    (auto-generated)
│   ├── autoload.php
│   ├── phpmailer/
│   │   └── phpmailer/
│   │       ├── src/
│   │       └── ...
│   └── ...
├── .htaccess
└── requests.log
```

---

## Next Steps

1. ✅ Deploy backend email files
2. ✅ Create email account on TheHost
3. ✅ Install PHPMailer via Composer
4. ✅ Test email sending
5. ⏭️ Integrate with Flutter app (already done!)
6. ⏭️ Test password reset flow
7. ⏭️ Monitor email delivery
8. ⏭️ Set up SPF/DKIM/DMARC records

---

## Support

If you encounter issues:

1. Check logs: `tail -f /var/log/php-errors.log`
2. Test SMTP: `telnet mail.opad.com.ua 587`
3. Verify .env: `cat .env`
4. Check permissions: `ls -la`
5. Contact TheHost support: https://thehost.ua/en/support

Good luck! 🚀
