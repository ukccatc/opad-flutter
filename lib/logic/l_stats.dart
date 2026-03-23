import 'package:flutter/material.dart';
import '../models/m_person_stats.dart';
import '../services/api_service.dart';
import '../utils/k.dart';
import '../utils/change_notifier_updater.dart';

class StatsLogic extends ChangeNotifier with ChangeNotifierUpdater {
  final ApiService _apiService = K.apiService;
  
  PersonStats? _stats;
  PersonStats? get stats => _stats;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchStats(String emailOrId) async {
    _isLoading = true;
    _error = null;
    update();
    
    try {
      _stats = await _apiService.getPersonStats(emailOrId);
    } catch (e) {
      _error = e.toString();
      K.showSnackBar('Ошибка при загрузке статистики: $e', isError: true);
    } finally {
      _isLoading = false;
      update();
    }
  }
}
