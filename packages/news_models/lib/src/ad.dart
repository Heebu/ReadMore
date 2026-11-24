/// Placement type for advertising units across the layout
enum AdPlacement {
  leaderboardBanner,
  inFeedNative,
  sidebarRectangle,
}

/// Format style of the ad
enum AdFormat {
  googleAdSense,
  sponsoredStory,
}

/// Sponsored Ad model supporting Google Ads and self-published partner campaigns
class SponsoredAd {
  final String id;
  final String title;
  final String description;
  final String sponsorName;
  final String? sponsorLogoUrl;
  final String? imageUrl;
  final String targetUrl;
  final String callToAction;
  final AdPlacement placement;
  final AdFormat format;
  final String targetCategory; // 'all', 'top', 'tech', 'business', etc.
  final double dailyBudget;
  final int impressions;
  final int clicks;
  final bool isActive;
  final DateTime createdAt;

  const SponsoredAd({
    required this.id,
    required this.title,
    required this.description,
    required this.sponsorName,
    this.sponsorLogoUrl,
    this.imageUrl,
    required this.targetUrl,
    this.callToAction = 'Learn More',
    required this.placement,
    this.format = AdFormat.googleAdSense,
    this.targetCategory = 'all',
    this.dailyBudget = 50.0,
    this.impressions = 1240,
    this.clicks = 86,
    this.isActive = true,
    required this.createdAt,
  });

  double get clickThroughRate =>
      impressions > 0 ? (clicks / impressions) * 100 : 0.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'sponsorName': sponsorName,
        'sponsorLogoUrl': sponsorLogoUrl,
        'imageUrl': imageUrl,
        'targetUrl': targetUrl,
        'callToAction': callToAction,
        'placement': placement.name,
        'format': format.name,
        'targetCategory': targetCategory,
        'dailyBudget': dailyBudget,
        'impressions': impressions,
        'clicks': clicks,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SponsoredAd.fromJson(Map<String, dynamic> json) => SponsoredAd(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        sponsorName: json['sponsorName'] as String,
        sponsorLogoUrl: json['sponsorLogoUrl'] as String?,
        imageUrl: json['imageUrl'] as String?,
        targetUrl: json['targetUrl'] as String,
        callToAction: json['callToAction'] as String? ?? 'Learn More',
        placement: AdPlacement.values.firstWhere(
          (e) => e.name == json['placement'],
          orElse: () => AdPlacement.leaderboardBanner,
        ),
        format: AdFormat.values.firstWhere(
          (e) => e.name == json['format'],
          orElse: () => AdFormat.googleAdSense,
        ),
        targetCategory: json['targetCategory'] as String? ?? 'all',
        dailyBudget: (json['dailyBudget'] as num?)?.toDouble() ?? 50.0,
        impressions: json['impressions'] as int? ?? 0,
        clicks: json['clicks'] as int? ?? 0,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  SponsoredAd copyWith({
    String? id,
    String? title,
    String? description,
    String? sponsorName,
    String? sponsorLogoUrl,
    String? imageUrl,
    String? targetUrl,
    String? callToAction,
    AdPlacement? placement,
    AdFormat? format,
    String? targetCategory,
    double? dailyBudget,
    int? impressions,
    int? clicks,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return SponsoredAd(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      sponsorName: sponsorName ?? this.sponsorName,
      sponsorLogoUrl: sponsorLogoUrl ?? this.sponsorLogoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      targetUrl: targetUrl ?? this.targetUrl,
      callToAction: callToAction ?? this.callToAction,
      placement: placement ?? this.placement,
      format: format ?? this.format,
      targetCategory: targetCategory ?? this.targetCategory,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      impressions: impressions ?? this.impressions,
      clicks: clicks ?? this.clicks,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
