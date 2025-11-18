class ArticleAttachment {
  final String name;
  final String url;
  final String? type;
  final int? size;

  ArticleAttachment({
    required this.name,
    required this.url,
    this.type,
    this.size,
  });

  factory ArticleAttachment.fromJson(Map<String, dynamic> json) {
    return ArticleAttachment(
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      type: json['type'] as String?,
      size: json['size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'type': type,
      'size': size,
    };
  }
}

class Article {
  final int id;
  final String title;
  final String content;
  final String? featuredImage;
  final DateTime date;
  final String? author;
  final String? excerpt;
  final List<String>? categories;
  final List<String>? tags;
  final List<ArticleAttachment>? attachments;
  final String? link;

  Article({
    required this.id,
    required this.title,
    required this.content,
    this.featuredImage,
    required this.date,
    this.author,
    this.excerpt,
    this.categories,
    this.tags,
    this.attachments,
    this.link,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? json['content']['rendered'] as String? ?? '',
      featuredImage: json['featured_image'] as String? ?? 
                     (json['_embedded']?['wp:featuredmedia']?[0]?['source_url'] as String?),
      date: DateTime.parse(json['date'] as String? ?? json['date_gmt'] as String? ?? DateTime.now().toIso8601String()),
      author: json['author'] as String? ?? json['author_name'] as String?,
      excerpt: json['excerpt'] as String? ?? json['excerpt']['rendered'] as String?,
      categories: json['categories'] != null 
          ? (json['categories'] as List).map((e) => e.toString()).toList()
          : null,
      tags: json['tags'] != null
          ? (json['tags'] as List).map((e) => e.toString()).toList()
          : null,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((e) => ArticleAttachment.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      link: json['link'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'featured_image': featuredImage,
      'date': date.toIso8601String(),
      'author': author,
      'excerpt': excerpt,
      'categories': categories,
      'tags': tags,
      'attachments': attachments?.map((e) => e.toJson()).toList(),
      'link': link,
    };
  }
}

