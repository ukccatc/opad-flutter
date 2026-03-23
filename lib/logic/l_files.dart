import 'package:flutter/material.dart';
import '../models/m_uploaded_file.dart';
import '../data/uploaded_files_data.dart';
import '../utils/change_notifier_updater.dart';

class FilesLogic extends ChangeNotifier with ChangeNotifierUpdater {
  List<UploadedFile> _allFiles = [];
  List<UploadedFile> _filteredFiles = [];
  
  List<UploadedFile> get files => _filteredFiles;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String _searchText = '';
  String _selectedYear = 'Всі роки';
  String _selectedType = 'Всі типи';
  
  String get searchText => _searchText;
  String get selectedYear => _selectedYear;
  String get selectedType => _selectedType;
  
  List<String> get years => ['Всі роки', ...UploadedFilesData.getYears().reversed];
  List<String> get types => ['Всі типи', 'PDF', 'DOC', 'DOCX'];

  FilesLogic() {
    _allFiles = UploadedFilesData.getAllFiles();
    _applyFilters();
  }

  void setSearchText(String text) {
    _searchText = text;
    _applyFilters();
  }

  void setSelectedYear(String year) {
    _selectedYear = year;
    _applyFilters();
  }

  void setSelectedType(String type) {
    _selectedType = type;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredFiles = _allFiles.where((file) {
      final matchesSearch = _searchText.isEmpty || 
          file.name.toLowerCase().contains(_searchText.toLowerCase()) ||
          (file.category?.toLowerCase().contains(_searchText.toLowerCase()) ?? false);
      
      final matchesYear = _selectedYear == 'Всі роки' || file.year == _selectedYear;
      
      final matchesType = _selectedType == 'Всі типи' || 
          file.type.toUpperCase() == _selectedType.toUpperCase();
          
      return matchesSearch && matchesYear && matchesType;
    }).toList();
    
    // Sort by year desc and then by name
    _filteredFiles.sort((a, b) {
      final yearCompare = b.year.compareTo(a.year);
      if (yearCompare != 0) return yearCompare;
      return a.name.compareTo(b.name);
    });
    
    update();
  }

  Future<void> fetchFiles() async {
    _isLoading = true;
    update();
    
    // Simulate API delay if needed, but currently using local data
    await Future.delayed(const Duration(milliseconds: 300));
    _allFiles = UploadedFilesData.getAllFiles();
    _applyFilters();
    
    _isLoading = false;
    update();
  }
}
