import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../logic/l_files.dart';
import '../models/m_uploaded_file.dart';
import '../utils/file_downloader.dart';
import '../utils/k.dart';
import '../utils/logger.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _downloadFile(UploadedFile file) async {
    try {
      if (kIsWeb) {
        // Show loading message
        K.showSnackBar('Завантаження файлу: ${file.displayName}...');

        // For web, use FileDownloader to download the file
        await FileDownloader.downloadFileAsBlob(file.url, file.name);

        K.showSnackBar('Файл завантажено: ${file.displayName}');
      } else {
        K.showSnackBar(
          'Скачування файлів доступне тільки для веб-версії',
          isError: true,
        );
      }
    } catch (e) {
      Logger.error('Error in _downloadFile: $e');
      K.showSnackBar(
        'Помилка завантаження файлу: ${e.toString()}',
        isError: true,
      );
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

  Color _getFileIconColor(BuildContext context, String type) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type.toLowerCase()) {
      case 'pdf':
        return colorScheme.error;
      case 'doc':
      case 'docx':
        return colorScheme.primary;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final logic = K.logicW<FilesLogic>(context);
    final files = logic.files;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Файли'),
        elevation: 0,
        actions: [
          // Show active filters count
          if (logic.selectedType != 'Всі типи' || logic.selectedYear != 'Всі роки')
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  '${(logic.selectedType != 'Всі типи' ? 1 : 0) + (logic.selectedYear != 'Всі роки' ? 1 : 0)}',
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
              _searchController.clear();
              logic.setSearchText('');
              logic.setSelectedYear('Всі роки');
              logic.setSelectedType('Всі типи');
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
                    color: Colors.black.withValues(alpha: 0.05),
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
                    onChanged: logic.setSearchText,
                    decoration: InputDecoration(
                      hintText: 'Пошук файлів...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                logic.setSearchText('');
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
                        children: logic.types.map((type) {
                          final isSelected = logic.selectedType == type;
                          return FilterChip(
                            label: Text(type),
                            selected: isSelected,
                            onSelected: (selected) {
                              logic.setSelectedType(type);
                            },
                          );
                        }).toList(),
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
                          children: logic.years.map((year) {
                            final isSelected = logic.selectedYear == year;
                            return FilterChip(
                              label: Text(year),
                              selected: isSelected,
                              onSelected: (selected) {
                                logic.setSelectedYear(year);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Files List
            Expanded(
              child: files.isEmpty
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
                          if (logic.selectedType != 'Всі типи' || logic.selectedYear != 'Всі роки' || logic.searchText.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                logic.setSearchText('');
                                logic.setSelectedYear('Всі роки');
                                logic.setSelectedType('Всі типи');
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
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getFileIconColor(
                                  context,
                                  file.type,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getFileIcon(file.type),
                                color: _getFileIconColor(context, file.type),
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
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer
                                            .withValues(alpha: 0.5),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Chip(
                                      label: Text(
                                        file.year,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .tertiaryContainer
                                          .withValues(alpha: 0.5),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
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
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
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
