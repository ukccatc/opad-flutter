import 'package:flutter/material.dart';
import '../models/m_person_stats.dart';
import '../services/api_service.dart';
import '../utils/k.dart';
import '../utils/change_notifier_updater.dart';

class BillingProfileLogic extends ChangeNotifier with ChangeNotifierUpdater {
  final ApiService _apiService = K.apiService;
  
  PersonStats? _account;
  PersonStats? get account => _account;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchAccount(String email) async {
    _isLoading = true;
    _error = null;
    update();
    
    try {
      _account = await _apiService.getPersonStats(email);
    } catch (e) {
      _error = e.toString();
      K.showSnackBar('Ошибка при загрузке данных аккаунта: $e', isError: true);
    } finally {
      _isLoading = false;
      update();
    }
  }
}
