import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../data/uploaded_files_data.dart';
import '../models/uploaded_file.dart';
import '../utils/file_downloader.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  List<UploadedFile> _filteredFiles = UploadedFilesData.getAllFiles();
  String? _selectedYear;
  String? _selectedType;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterFiles);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFiles() {
    setState(() {
      var files = UploadedFilesData.getAllFiles();

      // Filter by search query
      if (_searchController.text.isNotEmpty) {
        files = UploadedFilesData.searchFiles(_searchController.text);
      }

      // Filter by year
      if (_selectedYear != null) {
        files = files.where((f) => f.year == _selectedYear).toList();
      }

      // Filter by type
      if (_selectedType != null) {
        if (_selectedType == 'doc') {
          // Include both doc and docx for DOC filter
          files = files.where((f) => f.type == 'doc' || f.type == 'docx').toList();
        } else {
          files = files.where((f) => f.type == _selectedType).toList();
        }
      }

      _filteredFiles = files;
    });
  }

  Future<void> _downloadFile(UploadedFile file) async {
    try {
      if (kIsWeb) {
        print('Downloading file: ${file.name}');
        print('File URL: ${file.url}');
        print('File path: ${file.path}');
        
        // Show loading message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Завантаження файлу: ${file.displayName}...'),
              duration: const Duration(seconds: 2),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
        
        // For web, use FileDownloader to download the file
        await FileDownloader.downloadFileAsBlob(file.url, file.name);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Файл завантажено: ${file.displayName}'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // For other platforms, use url_launcher
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Скачування файлів доступне тільки для веб-версії'),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error in _downloadFile: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Помилка завантаження файлу: ${e.toString()}'),
            duration: const Duration(seconds: 4),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getFileIconColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final years = UploadedFilesData.getYears();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Файли'),
        elevation: 0,
        actions: [
          // Show active filters count
          if (_selectedType != null || _selectedYear != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  '${(_selectedType != null ? 1 : 0) + (_selectedYear != null ? 1 : 0)}',
                ),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                _selectedYear = null;
                _selectedType = null;
                _searchController.clear();
                _filteredFiles = UploadedFilesData.getAllFiles();
              });
            },
            tooltip: 'Очистити фільтри',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filters
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Пошук файлів...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter Sections
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type Filter Section
                      Text(
                        'Тип файлу:',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('Всі типи'),
                            selected: _selectedType == null,
                            onSelected: (selected) {
                              setState(() {
                                _selectedType = null;
                                _filterFiles();
                              });
                            },
                          ),
                          FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf_rounded,
                                  size: 16,
                                  color: _selectedType == 'pdf'
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                const Text('PDF'),
                              ],
                            ),
                            selected: _selectedType == 'pdf',
                            onSelected: (selected) {
                              setState(() {
                                _selectedType = selected ? 'pdf' : null;
                                _filterFiles();
                              });
                            },
                          ),
                          FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.description_rounded,
                                  size: 16,
                                  color: _selectedType == 'doc'
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Colors.blue,
                                ),
                                const SizedBox(width: 4),
                                const Text('DOC/DOCX'),
                              ],
                            ),
                            selected: _selectedType == 'doc',
                            onSelected: (selected) {
                              setState(() {
                                _selectedType = selected ? 'doc' : null;
                                _filterFiles();
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Year Filter Section
                      Text(
                        'Рік:',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilterChip(
                              label: const Text('Всі роки'),
                              selected: _selectedYear == null,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedYear = null;
                                  _filterFiles();
                                });
                              },
                            ),
                            ...years.map((year) {
                              return FilterChip(
                                label: Text(year),
                                selected: _selectedYear == year,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedYear = selected ? year : null;
                                    _filterFiles();
                                  });
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Files List
            Expanded(
              child: _filteredFiles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Файли не знайдено',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Спробуйте змінити фільтри пошуку',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          if (_selectedType != null || _selectedYear != null) ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedYear = null;
                                  _selectedType = null;
                                  _searchController.clear();
                                  _filteredFiles = UploadedFilesData.getAllFiles();
                                });
                              },
                              icon: const Icon(Icons.clear_all_rounded),
                              label: const Text('Очистити всі фільтри'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredFiles.length,
                      itemBuilder: (context, index) {
                        final file = _filteredFiles[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getFileIconColor(file.type)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getFileIcon(file.type),
                                color: _getFileIconColor(file.type),
                                size: 28,
                              ),
                            ),
                            title: Text(
                              file.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (file.category != null) ...[
                                      Chip(
                                        label: Text(
                                          file.category!,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Chip(
                                      label: Text(
                                        file.year,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const SizedBox(width: 8),
                                    if (file.size > 0)
                                      Text(
                                        file.formattedSize,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.download_rounded),
                              onPressed: () => _downloadFile(file),
                              tooltip: 'Завантажити',
                            ),
                            onTap: () => _downloadFile(file),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

