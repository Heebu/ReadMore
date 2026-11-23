/// Represents an authoritative publisher or news source (e.g. BBC, Reuters, TechCrunch)
class NewsSource {
  final String id;
  final String name;
  final String slug;
  final String domain;
  final String? iconUrl;
  final String? feedUrl;
  final String country;
  final String language;
  final double reliabilityScore; // 0.0 - 1.0
  final bool isVerified;

  const NewsSource({
    required this.id,
    required this.name,
    required this.slug,
    required this.domain,
    this.iconUrl,
    this.feedUrl,
    this.country = 'global',
    this.language = 'en',
    this.reliabilityScore = 0.9,
    this.isVerified = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'domain': domain,
        'iconUrl': iconUrl,
        'feedUrl': feedUrl,
        'country': country,
        'language': language,
        'reliabilityScore': reliabilityScore,
        'isVerified': isVerified,
      };

  factory NewsSource.fromJson(Map<String, dynamic> json) => NewsSource(
        id: json['id'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        domain: json['domain'] as String,
        iconUrl: json['iconUrl'] as String?,
        feedUrl: json['feedUrl'] as String?,
        country: json['country'] as String? ?? 'global',
        language: json['language'] as String? ?? 'en',
        reliabilityScore: (json['reliabilityScore'] as num?)?.toDouble() ?? 0.9,
        isVerified: json['isVerified'] as bool? ?? true,
      );
}
