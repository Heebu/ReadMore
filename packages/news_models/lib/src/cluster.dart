import 'article.dart';

/// Timeline chronological event for story clusters
class TimelineEvent {
  final String time;
  final String title;
  final String summary;
  final String sourceName;

  const TimelineEvent({
    required this.time,
    required this.title,
    required this.summary,
    required this.sourceName,
  });

  Map<String, dynamic> toJson() => {
        'time': time,
        'title': title,
        'summary': summary,
        'sourceName': sourceName,
      };

  factory TimelineEvent.fromJson(Map<String, dynamic> json) => TimelineEvent(
        time: json['time'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String,
        sourceName: json['sourceName'] as String,
      );
}

/// A clustered news event grouping multiple articles from different publishers
/// (Google News "Full Coverage" pattern)
class StoryCluster {
  final String id;
  final String topicHeadline;
  final String category;
  final Article primaryArticle;
  final List<Article> alternativePerspectives;
  final List<TimelineEvent> timeline;
  final DateTime updatedAt;

  const StoryCluster({
    required this.id,
    required this.topicHeadline,
    required this.category,
    required this.primaryArticle,
    this.alternativePerspectives = const [],
    this.timeline = const [],
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'topicHeadline': topicHeadline,
        'category': category,
        'primaryArticle': primaryArticle.toJson(),
        'alternativePerspectives': alternativePerspectives.map((e) => e.toJson()).toList(),
        'timeline': timeline.map((e) => e.toJson()).toList(),
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
        timeline: (json['timeline'] as List<dynamic>?)
                ?.map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
