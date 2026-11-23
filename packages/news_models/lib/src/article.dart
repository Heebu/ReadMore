import 'source.dart';

/// Represents a single news item parsed and aggregated from any publisher.
class Article {
  final String id;
  final String title;
  final String slug;
  final String summary;
  final String? content;
  final String originalUrl;
  final String? imageUrl;
  final NewsSource source;
  final String category;
  final String? subcategory;
  final List<String> tags;
  final DateTime publishedAt;
  final int readTimeMinutes;
  final bool isBreaking;
  final String? country;
  final String? city;
  final String? clusterId; // ID for grouping related articles (Google News "Full Coverage")
  final int viewCount;
  final int likeCount;
  final int bookmarkCount;
  final double? relevanceScore; // Dynamically calculated for For You feed

  const Article({
    required this.id,
    required this.title,
    required this.slug,
    required this.summary,
    this.content,
    required this.originalUrl,
    this.imageUrl,
    required this.source,
    required this.category,
    this.subcategory,
    this.tags = const [],
    required this.publishedAt,
    this.readTimeMinutes = 3,
    this.isBreaking = false,
    this.country,
    this.city,
    this.clusterId,
    this.viewCount = 0,
    this.likeCount = 0,
    this.bookmarkCount = 0,
    this.relevanceScore,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'slug': slug,
        'summary': summary,
        'content': content,
        'originalUrl': originalUrl,
        'imageUrl': imageUrl,
        'source': source.toJson(),
        'category': category,
        'subcategory': subcategory,
        'tags': tags,
        'publishedAt': publishedAt.toIso8601String(),
        'readTimeMinutes': readTimeMinutes,
        'isBreaking': isBreaking,
        'country': country,
        'city': city,
        'clusterId': clusterId,
        'viewCount': viewCount,
        'likeCount': likeCount,
        'bookmarkCount': bookmarkCount,
        'relevanceScore': relevanceScore,
      };

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        id: json['id'] as String,
        title: json['title'] as String,
        slug: json['slug'] as String,
        summary: json['summary'] as String,
        content: json['content'] as String?,
        originalUrl: json['originalUrl'] as String,
        imageUrl: json['imageUrl'] as String?,
        source: NewsSource.fromJson(json['source'] as Map<String, dynamic>),
        category: json['category'] as String,
        subcategory: json['subcategory'] as String?,
        tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
        publishedAt: DateTime.parse(json['publishedAt'] as String),
        readTimeMinutes: (json['readTimeMinutes'] as num?)?.toInt() ?? 3,
        isBreaking: json['isBreaking'] as bool? ?? false,
        country: json['country'] as String?,
        city: json['city'] as String?,
        clusterId: json['clusterId'] as String?,
        viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
        likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
        bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
        relevanceScore: (json['relevanceScore'] as num?)?.toDouble(),
      );

  Article copyWith({
    String? id,
    String? title,
    String? slug,
    String? summary,
    String? content,
    String? originalUrl,
    String? imageUrl,
    NewsSource? source,
    String? category,
    String? subcategory,
    List<String>? tags,
    DateTime? publishedAt,
    int? readTimeMinutes,
    bool? isBreaking,
    String? country,
    String? city,
    String? clusterId,
    int? viewCount,
    int? likeCount,
    int? bookmarkCount,
    double? relevanceScore,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      originalUrl: originalUrl ?? this.originalUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      tags: tags ?? this.tags,
      publishedAt: publishedAt ?? this.publishedAt,
      readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,
      isBreaking: isBreaking ?? this.isBreaking,
      country: country ?? this.country,
      city: city ?? this.city,
      clusterId: clusterId ?? this.clusterId,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      relevanceScore: relevanceScore ?? this.relevanceScore,
    );
  }
}
