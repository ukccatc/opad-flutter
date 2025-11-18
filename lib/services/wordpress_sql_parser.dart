// WordPress SQL Parser
// Parses WordPress SQL dump files to extract posts data

import 'dart:io';

class WordPressSqlParser {
  /// Parse WordPress SQL dump file and extract posts
  /// 
  /// SQL file should contain INSERT statements for wp_posts table
  /// Example: INSERT INTO `wp_posts` (`ID`, `post_author`, ...) VALUES (...)
  static Future<List<Map<String, dynamic>>> parsePostsFromSql(
    String sqlFilePath,
  ) async {
    final file = File(sqlFilePath);
    if (!await file.exists()) {
      throw Exception('SQL file not found: $sqlFilePath');
    }

    final content = await file.readAsString();
    final posts = <Map<String, dynamic>>[];

    // Extract table name (could be wp_posts, opad_posts, etc.)
    final tableMatch = RegExp(
      r"INSERT\s+INTO\s+`?(\w+_posts)`?\s*\(",
      caseSensitive: false,
    ).firstMatch(content);

    if (tableMatch == null) {
      throw Exception('No posts table found in SQL file');
    }

    // Extract column names from first INSERT statement
    final columnsMatch = RegExp(
      r"INSERT\s+INTO\s+`?\w+_posts`?\s*\(([^)]+)\)",
      caseSensitive: false,
    ).firstMatch(content);

    if (columnsMatch == null) {
      throw Exception('Could not parse column names from SQL file');
    }

    final columns = columnsMatch.group(1)!
        .split(',')
        .map((col) => col.trim().replaceAll('`', '').replaceAll("'", ''))
        .toList();

    // Extract all INSERT VALUES
    final valuesPattern = RegExp(
      r"VALUES\s*\(([^)]+(?:\([^)]*\)[^)]*)*)\)",
      caseSensitive: false,
      dotAll: true,
    );

    final valuesMatches = valuesPattern.allMatches(content);

    for (final match in valuesMatches) {
      final valuesString = match.group(1)!;
      final values = _parseSqlValues(valuesString, columns.length);

      if (values.length == columns.length) {
        final post = <String, dynamic>{};
        for (var i = 0; i < columns.length; i++) {
          post[columns[i]] = values[i];
        }
        posts.add(post);
      }
    }

    return posts;
  }

  /// Parse SQL VALUES string into list of values
  static List<dynamic> _parseSqlValues(String valuesString, int expectedCount) {
    final values = <dynamic>[];
    var currentValue = StringBuffer();
    var inQuotes = false;
    var quoteChar = '';
    var depth = 0;

    for (var i = 0; i < valuesString.length; i++) {
      final char = valuesString[i];

      if (!inQuotes && (char == '"' || char == "'")) {
        inQuotes = true;
        quoteChar = char;
        continue;
      }

      if (inQuotes && char == quoteChar && valuesString[i - 1] != '\\') {
        inQuotes = false;
        quoteChar = '';
        continue;
      }

      if (!inQuotes && char == '(') {
        depth++;
        currentValue.write(char);
        continue;
      }

      if (!inQuotes && char == ')') {
        depth--;
        currentValue.write(char);
        continue;
      }

      if (!inQuotes && char == ',' && depth == 0) {
        final value = currentValue.toString().trim();
        values.add(_parseSqlValue(value));
        currentValue.clear();
        continue;
      }

      currentValue.write(char);
    }

    // Add last value
    final value = currentValue.toString().trim();
    if (value.isNotEmpty) {
      values.add(_parseSqlValue(value));
    }

    return values;
  }

  /// Parse individual SQL value (handle NULL, strings, numbers)
  static dynamic _parseSqlValue(String value) {
    value = value.trim();

    if (value.toUpperCase() == 'NULL') {
      return null;
    }

    // Remove quotes if present
    if ((value.startsWith("'") && value.endsWith("'")) ||
        (value.startsWith('"') && value.endsWith('"'))) {
      value = value.substring(1, value.length - 1);
      // Unescape SQL strings
      value = value.replaceAll("\\'", "'");
      value = value.replaceAll('\\"', '"');
      value = value.replaceAll('\\\\', '\\');
      return value;
    }

    // Try to parse as number
    if (RegExp(r'^-?\d+$').hasMatch(value)) {
      return int.tryParse(value);
    }

    if (RegExp(r'^-?\d+\.\d+$').hasMatch(value)) {
      return double.tryParse(value);
    }

    return value;
  }

  /// Generate Dart code for articles_data.dart from parsed posts
  static String generateDartCode(List<Map<String, dynamic>> posts) {
    final buffer = StringBuffer();
    buffer.writeln('// WordPress Posts Data');
    buffer.writeln('// Auto-generated from WordPress SQL dump');
    buffer.writeln('// Total posts: ${posts.length}');
    buffer.writeln();
    buffer.writeln('class ArticlesData {');
    buffer.writeln('  static final List<Map<String, dynamic>> articles = [');

    for (var i = 0; i < posts.length; i++) {
      final post = posts[i];
      buffer.writeln('    {');
      
      post.forEach((key, value) {
        if (value == null) {
          buffer.writeln("      '$key': null,");
        } else if (value is String) {
          // Escape string for Dart
          final escaped = value
              .replaceAll('\\', '\\\\')
              .replaceAll("'", "\\'")
              .replaceAll('\n', '\\n')
              .replaceAll('\r', '\\r');
          buffer.writeln("      '$key': '$escaped',");
        } else if (value is int || value is double) {
          buffer.writeln("      '$key': $value,");
        } else {
          buffer.writeln("      '$key': '${value.toString()}',");
        }
      });
      
      buffer.write('    }');
      if (i < posts.length - 1) {
        buffer.write(',');
      }
      buffer.writeln();
    }

    buffer.writeln('  ];');
    buffer.writeln();
    buffer.writeln('  /// Find article by ID');
    buffer.writeln('  static Map<String, dynamic>? findById(int id) {');
    buffer.writeln('    try {');
    buffer.writeln('      return articles.firstWhere(');
    buffer.writeln('        (article) => article[\'ID\'] == id,');
    buffer.writeln('      );');
    buffer.writeln('    } catch (e) {');
    buffer.writeln('      return null;');
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln();
    buffer.writeln('  /// Get all published articles');
    buffer.writeln('  static List<Map<String, dynamic>> getPublishedArticles() {');
    buffer.writeln('    return articles.where(');
    buffer.writeln('      (article) => article[\'post_status\'] == \'publish\',');
    buffer.writeln('    ).toList();');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }
}

