// ignore_for_file: avoid_print
// Script to parse WordPress SQL dump and generate articles_data.dart
// Usage: dart scripts/parse_wordpress_posts.dart <path_to_sql_file>

import 'dart:io';
import 'package:flutter_opad/services/wordpress_sql_parser.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart scripts/parse_wordpress_posts.dart <path_to_sql_file>');
    print('');
    print('Example:');
    print('  dart scripts/parse_wordpress_posts.dart /path/to/wp_posts.sql');
    exit(1);
  }

  final sqlFilePath = args[0];
  print('Parsing WordPress SQL file: $sqlFilePath');

  try {
    final posts = await WordPressSqlParser.parsePostsFromSql(sqlFilePath);
    print('Found ${posts.length} posts');

    // Filter only published posts of type 'post'
    final publishedPosts = posts.where((post) {
      return post['post_status'] == 'publish' &&
          post['post_type'] == 'post';
    }).toList();

    print('Found ${publishedPosts.length} published posts');

    // Generate Dart code
    final dartCode = WordPressSqlParser.generateDartCode(publishedPosts);

    // Write to articles_data.dart
    final outputFile = File('lib/data/articles_data.dart');
    await outputFile.writeAsString(dartCode);
    print('Generated: lib/data/articles_data.dart');
    print('Successfully parsed ${publishedPosts.length} WordPress posts!');
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

