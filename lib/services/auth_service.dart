import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _loginKey = 'person_login';
  static const String _isLoggedInKey = 'is_logged_in';

  // Save login
  Future<void> saveLogin(String login) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loginKey, login);
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Get saved login
  Future<String?> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_loginKey);
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginKey);
    await prefs.setBool(_isLoggedInKey, false);
  }
}

