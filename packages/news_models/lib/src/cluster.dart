import 'article.dart';

/// A clustered news event grouping multiple articles from different publishers
/// (Google News "Full Coverage" pattern)
class StoryCluster {
  final String id;
  final String topicHeadline;
  final String category;
  final Article primaryArticle;
  final List<Article> alternativePerspectives;
  final DateTime updatedAt;

  const StoryCluster({
    required this.id,
    required this.topicHeadline,
    required this.category,
    required this.primaryArticle,
    this.alternativePerspectives = const [],
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'topicHeadline': topicHeadline,
        'category': category,
        'primaryArticle': primaryArticle.toJson(),
        'alternativePerspectives': alternativePerspectives.map((e) => e.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory StoryCluster.fromJson(Map<String, dynamic> json) => StoryCluster(
        id: json['id'] as String,
        topicHeadline: json['topicHeadline'] as String,
        category: json['category'] as String,
        primaryArticle: Article.fromJson(json['primaryArticle'] as Map<String, dynamic>),
        alternativePerspectives: (json['alternativePerspectives'] as List<dynamic>?)
                ?.map((e) => Article.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
