// lib/models/news_model.dart
class News {
  final int id;
  final String title;
  final String preview;
  final String? imageUrl;
  final int viewCount;
  int likeCount;
  final DateTime createdAt;

  News({
    required this.id,
    required this.title,
    required this.preview,
    this.imageUrl,
    required this.viewCount,
    required this.likeCount,
    required this.createdAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as int,
      title: json['title'] as String,
      preview: json['preview'] as String,
      imageUrl: json['image_url'] as String?,
      viewCount: json['view_count'] as int,
      likeCount: json['like_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'preview': preview,
    'image_url': imageUrl,
    'view_count': viewCount,
    'like_count': likeCount,
    'created_at': createdAt.toIso8601String(),
  };
}