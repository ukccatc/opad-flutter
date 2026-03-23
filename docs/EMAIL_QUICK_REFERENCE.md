# Email Implementation - Quick Reference

## 🚀 Quick Deploy (2 minutes)

```bash
cd flutter-opad
./QUICK_DEPLOY.sh username@opad.com.ua
```

Then enter your SMTP credentials when prompted.

---

## 📧 Backend Files

| File | Purpose | Status |
|------|---------|--------|
| `backend/EmailConfig.php` | SMTP configuration | ✅ Ready |
| `backend/EmailService.php` | Email sending | ✅ Ready |
| `backend/composer.json` | PHPMailer dependency | ✅ Ready |
| `backend/.env.example` | Config template | ✅ Ready |
| `backend/api.php` | API endpoints | ✅ Updated |

---

## 🎨 Frontend Files

| File | Purpose | Status |
|------|---------|--------|
| `lib/services/email_service.dart` | API calls | ✅ Ready |
| `lib/logic/l_email.dart` | State management | ✅ Ready |
| `lib/config/email_config.dart` | Configuration | ✅ Ready |
| `lib/models/m_email_response.dart` | Response model | ✅ Ready |
| `lib/widgets/email_status_widget.dart` | Status display | ✅ Ready |
| `lib/widgets/password_reset_dialog.dart` | Reset dialog | ✅ Ready |
| `lib/main.dart` | Provider setup | ✅ Updated |
| `lib/utils/k.dart` | Service access | ✅ Updated |

---

## 💻 API Endpoints

### Send Password Reset Email
```
POST /api/email/send-reset
{
  "email": "user@example.com",
  "name": "John Doe",
  "resetLink": "https://opad.com.ua/reset?token=abc123"
}
```

### Send Welcome Email
```
POST /api/email/send-welcome
{
  "email": "user@example.com",
  "name": "John Doe"
}
```

### Send Notification
```
POST /api/email/send-notification
{
  "email": "user@example.com",
  "name": "John Doe",
  "subject": "Subject",
  "message": "Message content"
}
```

---

## 🔧 Configuration

### Backend (.env)
```bash
SMTP_HOST=mail.opad.com.ua
SMTP_PORT=587
SMTP_USER=noreply@opad.com.ua
SMTP_PASSWORD=your_password
```

### Frontend (email_config.dart)
```dart
static const String supportEmail = 'noreply@opad.com.ua';
static const String resetLinkBase = 'https://opad.com.ua/reset';
```

---

## 📱 Flutter Usage

### Send Password Reset
```dart
final emailLogic = context.read<EmailLogic>();
await emailLogic.sendPasswordResetEmail(
  email: 'user@example.com',
  name: 'John Doe',
  token: 'token_123',
);
```

### Show Reset Dialog
```dart
showDialog(
  context: context,
  builder: (context) => PasswordResetDialog(
    onSuccess: () => K.showSnackBar('Check your email'),
  ),
);
```

### Send Welcome Email
```dart
await K.emailService.sendWelcomeEmail(
  email: 'user@example.com',
  name: 'John Doe',
);
```

### Display Status
```dart
EmailStatusWidget(
  onDismiss: () { /* handle */ },
)
```

---

## ✅ Deployment Steps

1. **Create email account** in cPanel
   - Email: `noreply@opad.com.ua`
   - Get SMTP credentials

2. **Run deployment script**
   ```bash
   ./QUICK_DEPLOY.sh username@opad.com.ua
   ```

3. **Test API endpoint**
   ```bash
   curl -X POST https://opad.com.ua/api/email/send-welcome \
     -H "Content-Type: application/json" \
     -d '{"email": "test@example.com", "name": "Test"}'
   ```

4. **Check email** - Should receive test email

5. **Integrate in Flutter** - Already done!

---

## 🧪 Test Commands

```bash
# Test welcome email
curl -X POST https://opad.com.ua/api/email/send-welcome \
  -H "Content-Type: application/json" \
  -d '{"email": "your_email@example.com", "name": "Test User"}'

# Test password reset
curl -X POST https://opad.com.ua/api/email/send-reset \
  -H "Content-Type: application/json" \
  -d '{"email": "your_email@example.com", "name": "Test", "resetLink": "https://opad.com.ua/reset?token=test"}'

# Check server logs
ssh username@opad.com.ua
tail -f /var/log/mail.log
```

---

## 🐛 Quick Fixes

| Issue | Solution |
|-------|----------|
| Email not sending | Check .env credentials |
| Composer not found | Run `curl -sS https://getcomposer.org/installer \| php` |
| Permission denied | Run `chmod 600 .env` |
| SMTP connection failed | Verify port 587 is open |
| Email going to spam | Add SPF/DKIM records |

---

## 📚 Full Documentation

- **DEPLOY_EMAIL_BACKEND.md** - Complete deployment guide
- **FLUTTER_EMAIL_USAGE.md** - Flutter integration guide
- **EMAIL_SETUP_GUIDE.md** - Detailed setup instructions
- **EMAIL_IMPLEMENTATION_SUMMARY.md** - Full summary

---

## 🎯 Status

✅ **Backend**: Ready to deploy
✅ **Frontend**: Ready to use
✅ **Documentation**: Complete
✅ **Testing**: Ready

**Next**: Run `./QUICK_DEPLOY.sh username@opad.com.ua`

---

## 📞 Need Help?

1. Check the relevant documentation
2. Review error logs: `tail -f /var/log/php-errors.log`
3. Test SMTP: `telnet mail.opad.com.ua 587`
4. Contact TheHost: https://thehost.ua/en/support

---

**Everything is ready to go! 🚀**
