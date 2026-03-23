# Quick Start Guide - MySQL Connection

## 🎯 5-Minute Setup

### Step 1: Verify Configuration
Check `lib/config/database_config.dart`:
```dart
static String host = 's19.thehost.com.ua';
static String database = 'opad';
static String username = 'opad2016';
static String password = 'opad2016';
```

### Step 2: Test Connection
```bash
cd flutter-opad
dart test_fetch_data.dart
```

### Step 3: Check Output
Look for:
- ✅ "Successfully connected to MySQL!"
- ✅ Database statistics
- ✅ User list with names and balances

## 🚀 Using in Your App

### Get User Billing Data
```dart
import 'services/sql_service.dart';

final sqlService = SqlService();
final userStats = await sqlService.getPersonStatsFromSql('user@email.com');

print('Name: ${userStats.fullName}');
print('Balance: ${userStats.totalAmount} грн');
print('Union Member: ${userStats.isUnionMember}');
```

### Authenticate User
```dart
final isValid = await sqlService.authenticatePerson(
  'user@email.com',
  'password'
);

if (isValid) {
  print('Login successful!');
}
```

### Get All Users
```dart
final allUsers = await sqlService.getAllUsers();
for (var user in allUsers) {
  print('${user.fullName}: ${user.totalAmount} грн');
}
```

### Get Union Members
```dart
final unionMembers = await sqlService.getUnionMembers();
print('Union members: ${unionMembers.length}');
```

## 📊 Display Billing Profile

```dart
import 'screens/billing_profile_screen.dart';

// Navigate to billing profile
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BillingProfileScreen(
      userEmail: 'user@email.com',
    ),
  ),
);
```

## 🧪 Test Commands

### Simple Connection Test
```bash
dart test_connection.dart
```

### Fetch Data Test
```bash
dart test_fetch_data.dart
```

### Full Test Suite
```bash
dart test_mysql.dart
```

## ❌ Troubleshooting

### "Connection refused"
- Check if MySQL server is running
- Verify host: `ping s19.thehost.com.ua`
- Check firewall settings

### "Access denied"
- Verify username: `opad2016`
- Verify password: `opad2016`
- Check user permissions

### "Unknown database"
- Verify database name: `opad`
- Check if database exists

### "Timeout"
- Increase timeout in `database_config.dart`
- Check network connectivity
- Verify MySQL server is responding

## 📚 Documentation

- **Full Guide**: See `MYSQL_CONNECTION_GUIDE.md`
- **Setup Details**: See `SETUP_SUMMARY.md`
- **Code Examples**: See `lib/screens/billing_profile_screen.dart`

## ✅ Checklist

- [ ] Configuration verified in `database_config.dart`
- [ ] Test connection successful
- [ ] Data fetching works
- [ ] User authentication works
- [ ] Billing profile screen displays correctly
- [ ] Ready for production

## 🎓 Key Concepts

### SqlService
Main service for database operations:
```dart
final sqlService = SqlService();
await sqlService.initialize();
```

### MySqlService
Low-level MySQL connection:
```dart
final mysqlService = MySqlService();
await mysqlService.connect();
```

### DatabaseConfig
Configuration management:
```dart
DatabaseConfig.host = 'your-server.com';
DatabaseConfig.initialize();
```

### PersonStats
User data model:
```dart
PersonStats {
  id: String,
  email: String,
  fullName: String,
  totalAmount: int,
  isUnionMember: bool,
}
```

## 🔐 Security Notes

⚠️ **For Development Only**: Direct MySQL connections expose credentials

**For Production**:
1. Create REST API
2. Use API endpoints
3. Implement proper authentication
4. Use HTTPS
5. Never hardcode credentials

## 📞 Need Help?

1. Check test output for error messages
2. Review `MYSQL_CONNECTION_GUIDE.md`
3. Verify MySQL server is running
4. Check network connectivity
5. Contact database administrator

---

**Ready to go!** 🚀