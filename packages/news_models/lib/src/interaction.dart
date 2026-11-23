/// Types of user interactions used for telemetry and "For You" algorithm learning
enum InteractionType {
  click,
  dwell30s, // Stayed on article >= 30 seconds (deep read signal)
  like,
  unlike,
  bookmark,
  unbookmark,
  readLater,
  share,
  hideSource,
  fewerStoriesLikeThis,
}

/// Recorded telemetry event for user engagement
class UserInteraction {
  final String id;
  final String userId;
  final String articleId;
  final InteractionType type;
  final int dwellTimeSeconds;
  final DateTime createdAt;

  const UserInteraction({
    required this.id,
    required this.userId,
    required this.articleId,
    required this.type,
    this.dwellTimeSeconds = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'articleId': articleId,
        'type': type.name,
        'dwellTimeSeconds': dwellTimeSeconds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserInteraction.fromJson(Map<String, dynamic> json) => UserInteraction(
        id: json['id'] as String,
        userId: json['userId'] as String,
        articleId: json['articleId'] as String,
        type: InteractionType.values.byName(json['type'] as String),
        dwellTimeSeconds: (json['dwellTimeSeconds'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

/// An entry in the user's Bookmarks or Read Later queue
class SavedArticleItem {
  final String id;
  final String userId;
  final String articleId;
  final bool isReadLater; // true = Read Later, false = Favorite/Bookmark
  final bool isArchived;
  final DateTime savedAt;

  const SavedArticleItem({
    required this.id,
    required this.userId,
    required this.articleId,
    this.isReadLater = false,
    this.isArchived = false,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'articleId': articleId,
        'isReadLater': isReadLater,
        'isArchived': isArchived,
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedArticleItem.fromJson(Map<String, dynamic> json) => SavedArticleItem(
        id: json['id'] as String,
        userId: json['userId'] as String,
        articleId: json['articleId'] as String,
        isReadLater: json['isReadLater'] as bool? ?? false,
        isArchived: json['isArchived'] as bool? ?? false,
        savedAt: DateTime.parse(json['savedAt'] as String),
      );
}
