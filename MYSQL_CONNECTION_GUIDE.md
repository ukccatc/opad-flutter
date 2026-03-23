# MySQL Connection Guide for Flutter OPAD App

## Overview
This guide explains how to connect the Flutter OPAD app to the WordPress MySQL database and fetch user billing data.

## Database Configuration

### Current Settings
- **Host**: `s19.thehost.com.ua`
- **Port**: `3306`
- **Database**: `opad`
- **Username**: `opad2016`
- **Password**: `opad2016`

### Configuration File
Edit `lib/config/database_config.dart` to change connection settings:

```dart
static String host = 's19.thehost.com.ua';
static int port = 3306;
static String database = 'opad';
static String username = 'opad2016';
static String password = 'opad2016';
```

## Testing the Connection

### Test 1: Simple Connection Test
```bash
dart test_connection.dart
```

This test will:
- Attempt to connect to MySQL
- Run a simple query to verify connection
- Display database statistics

### Test 2: Fetch Data Test
```bash
dart test_fetch_data.dart
```

This comprehensive test will:
- Connect to MySQL
- Fetch all users from Stats table
- Fetch union members
- Test authentication
- Display formatted data tables

### Test 3: Full Test Suite
```bash
dart test_mysql.dart
```

This test will:
- Test connection
- Get database statistics
- Fetch all users
- Fetch union members
- Test authentication with test user
- Display detailed information

## Data Structure

### Stats Table
Contains user profile and billing information:
- `Id` (VARCHAR): User ID
- `Email` (VARCHAR): User email
- `Password` (VARCHAR): MD5 hashed password
- `Член-профсоюза` (INT): Union member status (0 or 1)
- `ФИО` (VARCHAR): Full name in Russian
- `Общая сумма` (INT): Total billing amount

### Users Table
Contains authentication information:
- `id` (INT): Record ID
- `Email` (VARCHAR): User email
- `Password` (VARCHAR): MD5 hashed password
- `user_id` (INT): Reference to Stats table ID

## Flutter App Integration

### Initialize MySQL Connection
The app automatically initializes MySQL connection on startup in `main.dart`:

```dart
// Initialize database configuration
DatabaseConfig.initialize();

// Initialize MySQL connection
final sqlService = SqlService();
await sqlService.initialize();
```

### Using SqlService in Your Code

```dart
import 'services/sql_service.dart';

final sqlService = SqlService();

// Get user stats
final userStats = await sqlService.getPersonStatsFromSql('user@email.com');
print('User: ${userStats.fullName}');
print('Balance: ${userStats.totalAmount}');

// Authenticate user
final isValid = await sqlService.authenticatePerson('user@email.com', 'password');

// Get all users
final allUsers = await sqlService.getAllUsers();

// Get union members
final unionMembers = await sqlService.getUnionMembers();

// Get database stats
final stats = await sqlService.getDatabaseStats();
```

## Troubleshooting

### Connection Refused
**Problem**: `Connection refused` error

**Solutions**:
1. Verify MySQL server is running on `s19.thehost.com.ua`
2. Check if port 3306 is open and accessible
3. Verify firewall rules allow MySQL connections
4. Try connecting from command line: `mysql -h s19.thehost.com.ua -u opad2016 -p`

### Access Denied
**Problem**: `Access denied for user 'opad2016'@'...'`

**Solutions**:
1. Verify username and password are correct
2. Check if user has remote access permissions
3. Run on MySQL server: `GRANT ALL ON opad.* TO 'opad2016'@'%';`
4. Flush privileges: `FLUSH PRIVILEGES;`

### Database Not Found
**Problem**: `Unknown database 'opad'`

**Solutions**:
1. Verify database name is correct
2. Check if database exists: `SHOW DATABASES;`
3. Create database if needed: `CREATE DATABASE opad;`

### Timeout
**Problem**: Connection times out

**Solutions**:
1. Increase timeout in `database_config.dart`: `static const int connectTimeout = 60;`
2. Check network connectivity: `ping s19.thehost.com.ua`
3. Verify MySQL server is responding
4. Check firewall rules

### SSL/TLS Issues
**Problem**: SSL certificate errors

**Solutions**:
1. For development, disable SSL in `database_config.dart`:
   ```dart
   static bool secure = false;
   static bool allowInsecure = true;
   ```
2. For production, use proper SSL certificates

## Security Considerations

⚠️ **WARNING**: Direct MySQL connections from mobile apps expose database credentials!

### For Production:
1. **Create a REST API** instead of direct database connections
2. **Use API endpoints** for all data access
3. **Implement authentication** at the API level
4. **Use HTTPS** for all API calls
5. **Never hardcode credentials** in the app

### Recommended Architecture:
```
Flutter App → REST API (PHP/Node.js) → MySQL Database
```

### Example API Endpoints:
- `POST /api/auth/login` - Authenticate user
- `GET /api/user/stats` - Get user statistics
- `GET /api/user/billing` - Get billing information
- `POST /api/user/password-reset` - Reset password

## Performance Tips

1. **Connection Pooling**: Reuse connections instead of creating new ones
2. **Query Optimization**: Use indexes on frequently queried columns
3. **Caching**: Cache user data locally with SharedPreferences
4. **Pagination**: Fetch data in batches for large datasets
5. **Async Operations**: Always use async/await for database operations

## Database Optimization

### Recommended Indexes:
```sql
CREATE INDEX idx_email ON Stats(Email);
CREATE INDEX idx_union ON Stats(`Член-профсоюза`);
CREATE INDEX idx_user_email ON Users(Email);
```

### Query Examples:
```sql
-- Get user by email
SELECT * FROM Stats WHERE Email = 'user@email.com';

-- Get union members
SELECT * FROM Stats WHERE `Член-профсоюза` = 1;

-- Get total balance
SELECT SUM(`Общая сумма`) FROM Stats;

-- Get user count
SELECT COUNT(*) FROM Stats;
```

## Next Steps

1. ✅ Test connection using provided test scripts
2. ✅ Verify data is accessible
3. ✅ Implement billing screens in Flutter app
4. ✅ Add user profile screen
5. ✅ Implement payment history
6. ✅ Create API layer for production
7. ✅ Implement proper authentication
8. ✅ Add data caching and offline support

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review test output for error messages
3. Check MySQL server logs
4. Verify network connectivity
5. Contact database administrator

## References

- [MySQL Documentation](https://dev.mysql.com/doc/)
- [Dart MySQL Package](https://pub.dev/packages/mysql1)
- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)
- [REST API Design](https://restfulapi.net/)