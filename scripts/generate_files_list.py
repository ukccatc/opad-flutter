#!/usr/bin/env python3
"""
Generate uploaded_files_data.dart from all files in web/assets/uploads/
"""
import os
from pathlib import Path

def main():
    target_dir = Path("/Users/macbookpro/Git Actions/flutter-opad/web/assets/uploads")
    data_file = Path("/Users/macbookpro/Git Actions/flutter-opad/lib/data/uploaded_files_data.dart")
    
    print("=" * 70)
    print("GENERATING FILE LIST FROM UPLOADS FOLDER")
    print("=" * 70)
    
    if not target_dir.exists():
        print(f"\n❌ Uploads directory not found: {target_dir}")
        return False
    
    # Find all files
    all_files = []
    for root, dirs, files in os.walk(target_dir):
        for file in files:
            if file.lower().endswith(('.pdf', '.doc', '.docx')):
                file_path = Path(root) / file
                rel_path = file_path.relative_to(target_dir)
                size = file_path.stat().st_size
                
                # Determine type
                if file.lower().endswith('.pdf'):
                    file_type = 'pdf'
                elif file.lower().endswith('.docx'):
                    file_type = 'docx'
                else:
                    file_type = 'doc'
                
                # Extract year
                year = rel_path.parts[0] if len(rel_path.parts) > 0 else 'unknown'
                
                # Determine category
                name_lower = file.lower()
                category = 'Документи'
                if 'протокол' in name_lower or 'protocol' in name_lower:
                    category = 'Протоколи'
                elif 'договор' in name_lower or 'дог' in name_lower or 'kd' in name_lower or 'кд' in name_lower:
                    category = 'Договори'
                elif 'статут' in name_lower or 'устав' in name_lower:
                    category = 'Статути'
                elif 'положення' in name_lower:
                    category = 'Положення'
                elif 'реквизит' in name_lower:
                    category = 'Реквізити'
                elif 'галузева' in name_lower or 'угода' in name_lower:
                    category = 'Угоди'
                elif 'стратег' in name_lower:
                    category = 'Стратегічні плани'
                elif 'страховк' in name_lower or 'гендоговір' in name_lower:
                    category = 'Страхування'
                
                all_files.append({
                    'name': file,
                    'path': str(rel_path),
                    'type': file_type,
                    'size': size,
                    'year': year,
                    'category': category,
                })
    
    print(f"\nFound {len(all_files)} files")
    
    # Sort by year and name
    all_files.sort(key=lambda x: (x['year'], x['name']))
    
    # Generate Dart code
    dart_code = '''// Uploaded Files Data
// Contains list of PDF and DOC files from WordPress uploads folder
// Auto-generated from web/assets/uploads/ directory

import '../models/uploaded_file.dart';

class UploadedFilesData {
  static final List<UploadedFile> files = [
'''
    
    # Add files
    for f in all_files:
        # Escape single quotes
        name_escaped = f['name'].replace("'", "\\'")
        path_escaped = f['path'].replace("'", "\\'")
        
        dart_code += f'''    UploadedFile(
      name: '{name_escaped}',
      path: '{path_escaped}',
      type: '{f['type']}',
      size: {f['size']},
      year: '{f['year']}',
      category: '{f['category']}',
    ),
'''
    
    dart_code += '''  ];

  /// Get all files
  static List<UploadedFile> getAllFiles() {
    return files;
  }

  /// Get files by type
  static List<UploadedFile> getFilesByType(String type) {
    return files.where((file) => file.type == type.toLowerCase()).toList();
  }

  /// Get files by year
  static List<UploadedFile> getFilesByYear(String year) {
    return files.where((file) => file.year == year).toList();
  }

  /// Get files by category
  static List<UploadedFile> getFilesByCategory(String category) {
    return files.where((file) => file.category == category).toList();
  }

  /// Search files by name
  static List<UploadedFile> searchFiles(String query) {
    final lowerQuery = query.toLowerCase();
    return files.where((file) {
      return file.name.toLowerCase().contains(lowerQuery) ||
          file.displayName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get all unique categories
  static List<String> getCategories() {
    return files
        .where((file) => file.category != null)
        .map((file) => file.category!)
        .toSet()
        .toList()
      ..sort();
  }

  /// Get all unique years
  static List<String> getYears() {
    return files.map((file) => file.year).toSet().toList()..sort();
  }
}
'''
    
    # Write to file
    with open(data_file, 'w', encoding='utf-8') as f:
        f.write(dart_code)
    
    print(f"✓ Generated uploaded_files_data.dart with {len(all_files)} files")
    
    # Statistics
    pdf_count = len([f for f in all_files if f['type'] == 'pdf'])
    doc_count = len([f for f in all_files if f['type'] in ['doc', 'docx']])
    years = sorted(set(f['year'] for f in all_files))
    categories = sorted(set(f['category'] for f in all_files))
    
    print(f"\nStatistics:")
    print(f"  PDF: {pdf_count}")
    print(f"  DOC/DOCX: {doc_count}")
    print(f"  Years: {', '.join(years)}")
    print(f"  Categories: {len(categories)}")
    
    print(f"\n{'=' * 70}")
    print("✓ FILE LIST GENERATED SUCCESSFULLY!")
    print("=" * 70)
    
    return True

if __name__ == "__main__":
    main()

