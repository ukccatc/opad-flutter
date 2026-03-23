import 'package:flutter/material.dart';
import '../models/m_article.dart';
import '../services/api_service.dart';
import '../utils/k.dart';
import '../utils/change_notifier_updater.dart';

class ArticlesLogic extends ChangeNotifier with ChangeNotifierUpdater {
  final ApiService _apiService = K.apiService;
  
  List<Article> _articles = [];
  List<Article> get articles => _articles;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchArticles() async {
    _isLoading = true;
    _error = null;
    update();
    
    try {
      _articles = await _apiService.getArticles();
    } catch (e) {
      _error = e.toString();
      K.showSnackBar('Ошибка при загрузке новостей: $e', isError: true);
    } finally {
      _isLoading = false;
      update();
    }
  }
}
