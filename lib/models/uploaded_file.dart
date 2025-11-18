class UploadedFile {
  final String name;
  final String path;
  final String type; // 'pdf', 'doc', 'docx'
  final int size; // in bytes
  final String year;
  final String? category; // Optional category

  UploadedFile({
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    required this.year,
    this.category,
  });

  /// Get the URL for the file
  /// For web, files are served from /assets/uploads/ directory
  String get url {
    // Ensure path uses forward slashes
    final normalizedPath = path.replaceAll('\\', '/');
    return '/assets/uploads/$normalizedPath';
  }

  /// Get display name for the file
  /// Uses the name field which should already be formatted as a readable title
  String get displayName {
    // Name should already be formatted, but clean up if needed
    String result = name;
    
    // Remove file extension if present
    if (result.endsWith('.pdf') || result.endsWith('.doc') || result.endsWith('.docx')) {
      result = result.substring(0, result.lastIndexOf('.'));
    }
    
    // Replace common separators
    result = result.replaceAll('-', ' ');
    result = result.replaceAll('_', ' ');
    
    // Clean up multiple spaces
    result = result.replaceAll(RegExp(r'\s+'), ' ');
    
    return result.trim();
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory UploadedFile.fromJson(Map<String, dynamic> json) {
    return UploadedFile(
      name: json['name'] as String,
      path: json['path'] as String,
      type: json['type'] as String,
      size: json['size'] as int,
      year: json['year'] as String,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'type': type,
      'size': size,
      'year': year,
      'category': category,
    };
  }
}

