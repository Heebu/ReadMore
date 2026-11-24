/// User comment on a news article with community engagement metrics
class ArticleComment {
  final String id;
  final String articleId;
  final String author;
  final String avatarUrl;
  final String text;
  final String timeAgo;
  final DateTime createdAt;
  int likes;
  bool isLiked;

  ArticleComment({
    required this.id,
    this.articleId = '',
    required this.author,
    required this.avatarUrl,
    required this.text,
    required this.timeAgo,
    DateTime? createdAt,
    this.likes = 0,
    this.isLiked = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'articleId': articleId,
        'author': author,
        'avatarUrl': avatarUrl,
        'text': text,
        'timeAgo': timeAgo,
        'createdAt': createdAt.toIso8601String(),
        'likes': likes,
        'isLiked': isLiked,
      };

  factory ArticleComment.fromJson(Map<String, dynamic> json) => ArticleComment(
        id: json['id'] as String,
        articleId: json['articleId'] as String? ?? '',
        author: json['author'] as String,
        avatarUrl: json['avatarUrl'] as String? ??
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop',
        text: json['text'] as String,
        timeAgo: json['timeAgo'] as String? ?? 'Just now',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        likes: (json['likes'] as num?)?.toInt() ?? 0,
        isLiked: json['isLiked'] as bool? ?? false,
      );

  ArticleComment copyWith({
    String? id,
    String? articleId,
    String? author,
    String? avatarUrl,
    String? text,
    String? timeAgo,
    DateTime? createdAt,
    int? likes,
    bool? isLiked,
  }) {
    return ArticleComment(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      author: author ?? this.author,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      text: text ?? this.text,
      timeAgo: timeAgo ?? this.timeAgo,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
