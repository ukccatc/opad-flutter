import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/k.dart';
import '../utils/change_notifier_updater.dart';

class LoginLogic extends ChangeNotifier with ChangeNotifierUpdater {
  final AuthService _authService = K.authService;
  final ApiService _apiService = K.apiService;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    update();
    
    try {
      final success = await _apiService.authenticatePerson(email, password);
      if (success) {
        await _authService.saveLogin(email);
      } else {
        _error = 'Невірний email або пароль';
      }
      return success;
    } catch (e) {
      _error = 'Помилка при вході: $e';
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }

  void logout() {
    _authService.logout();
    update();
  }
}
