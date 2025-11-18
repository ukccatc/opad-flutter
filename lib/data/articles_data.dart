// WordPress Posts Data
// This file contains parsed WordPress posts from SQL database
// Table: wp_posts (or opad_posts depending on table prefix)

class ArticlesData {
  // Static list of articles parsed from WordPress SQL dump
  // Structure matches WordPress wp_posts table:
  // ID, post_author, post_date, post_date_gmt, post_content, post_title,
  // post_excerpt, post_status, comment_status, ping_status, post_password,
  // post_name, to_ping, pinged, post_modified, post_modified_gmt,
  // post_content_filtered, post_parent, guid, menu_order, post_type,
  // post_mime_type, comment_count
  
  static final List<Map<String, dynamic>> articles = [
    // Articles will be added here after parsing SQL file
    // Example structure:
    // {
    //   'ID': 1,
    //   'post_title': 'Article Title',
    //   'post_content': 'Article content...',
    //   'post_excerpt': 'Article excerpt...',
    //   'post_date': '2024-01-01 12:00:00',
    //   'post_author': 1,
    //   'post_status': 'publish',
    //   'post_type': 'post',
    //   'guid': 'http://opad.com.ua/?p=1',
    //   'post_name': 'article-title',
    // }
  ];

  /// Find article by ID
  static Map<String, dynamic>? findById(int id) {
    try {
      return articles.firstWhere(
        (article) => article['ID'] == id,
      );
    } catch (e) {
      return null;
    }
  }

  /// Find articles by post status (e.g., 'publish', 'draft')
  static List<Map<String, dynamic>> findByStatus(String status) {
    return articles.where(
      (article) => article['post_status'] == status,
    ).toList();
  }

  /// Get all published articles
  static List<Map<String, dynamic>> getPublishedArticles() {
    return findByStatus('publish');
  }

  /// Find articles by post type (e.g., 'post', 'page')
  static List<Map<String, dynamic>> findByType(String type) {
    return articles.where(
      (article) => article['post_type'] == type,
    ).toList();
  }

  /// Search articles by title or content
  static List<Map<String, dynamic>> search(String query) {
    final lowerQuery = query.toLowerCase();
    return articles.where((article) {
      final title = (article['post_title'] as String? ?? '').toLowerCase();
      final content = (article['post_content'] as String? ?? '').toLowerCase();
      return title.contains(lowerQuery) || content.contains(lowerQuery);
    }).toList();
  }
}

