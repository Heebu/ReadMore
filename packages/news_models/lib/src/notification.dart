/// Real-time intelligence dispatch alert / notification
class AppNotification {
  final String id;
  final String title;
  final String timeAgo;
  final bool isBreaking;
  final String articleId;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.timeAgo,
    this.isBreaking = false,
    required this.articleId,
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'timeAgo': timeAgo,
        'isBreaking': isBreaking,
        'articleId': articleId,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        timeAgo: json['timeAgo'] as String? ?? 'Just now',
        isBreaking: json['isBreaking'] as bool? ?? false,
        articleId: json['articleId'] as String? ?? '',
        isRead: json['isRead'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  AppNotification copyWith({
    String? id,
    String? title,
    String? timeAgo,
    bool? isBreaking,
    String? articleId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      timeAgo: timeAgo ?? this.timeAgo,
      isBreaking: isBreaking ?? this.isBreaking,
      articleId: articleId ?? this.articleId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
