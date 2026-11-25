/// User preference profile controlling algorithmic recommendations
class UserPreferences {
  final List<String> followedTopics;
  final List<String> mutedTopics;
  final List<String> blockedSources;
  final List<String> favoriteSources;
  final String? preferredLanguage;
  final String? locationCity;
  final String? locationCountry;
  final double? latitude;
  final double? longitude;
  final bool enableBreakingAlerts;
  final bool enableDailyBriefing;
  final bool audioAutoplay;
  final bool darkMode;

  const UserPreferences({
    this.followedTopics = const ['top', 'tech', 'business'],
    this.mutedTopics = const [],
    this.blockedSources = const [],
    this.favoriteSources = const [],
    this.preferredLanguage = 'en',
    this.locationCity = 'New York',
    this.locationCountry = 'United States',
    this.latitude,
    this.longitude,
    this.enableBreakingAlerts = true,
    this.enableDailyBriefing = true,
    this.audioAutoplay = true,
    this.darkMode = true,
  });

  Map<String, dynamic> toJson() => {
        'followedTopics': followedTopics,
        'mutedTopics': mutedTopics,
        'blockedSources': blockedSources,
        'favoriteSources': favoriteSources,
        'preferredLanguage': preferredLanguage,
        'locationCity': locationCity,
        'locationCountry': locationCountry,
        'latitude': latitude,
        'longitude': longitude,
        'enableBreakingAlerts': enableBreakingAlerts,
        'enableDailyBriefing': enableDailyBriefing,
        'audioAutoplay': audioAutoplay,
        'darkMode': darkMode,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) => UserPreferences(
        followedTopics: (json['followedTopics'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const ['top', 'tech', 'business'],
        mutedTopics: (json['mutedTopics'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
        blockedSources: (json['blockedSources'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
        favoriteSources: (json['favoriteSources'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
        preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
        locationCity: json['locationCity'] as String? ?? 'New York',
        locationCountry: json['locationCountry'] as String? ?? 'United States',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        enableBreakingAlerts: json['enableBreakingAlerts'] as bool? ?? true,
        enableDailyBriefing: json['enableDailyBriefing'] as bool? ?? true,
        audioAutoplay: json['audioAutoplay'] as bool? ?? true,
        darkMode: json['darkMode'] as bool? ?? true,
      );

  UserPreferences copyWith({
    List<String>? followedTopics,
    List<String>? mutedTopics,
    List<String>? blockedSources,
    List<String>? favoriteSources,
    String? preferredLanguage,
    String? locationCity,
    String? locationCountry,
    double? latitude,
    double? longitude,
    bool? enableBreakingAlerts,
    bool? enableDailyBriefing,
    bool? audioAutoplay,
    bool? darkMode,
  }) {
    return UserPreferences(
      followedTopics: followedTopics ?? this.followedTopics,
      mutedTopics: mutedTopics ?? this.mutedTopics,
      blockedSources: blockedSources ?? this.blockedSources,
      favoriteSources: favoriteSources ?? this.favoriteSources,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      locationCity: locationCity ?? this.locationCity,
      locationCountry: locationCountry ?? this.locationCountry,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      enableBreakingAlerts: enableBreakingAlerts ?? this.enableBreakingAlerts,
      enableDailyBriefing: enableDailyBriefing ?? this.enableDailyBriefing,
      audioAutoplay: audioAutoplay ?? this.audioAutoplay,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}

/// User account entity with subscription and streak metrics
class User {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String role; // 'user', 'editor', 'admin', 'publisher'
  final DateTime createdAt;
  final UserPreferences preferences;
  final String subscriptionTier; // 'free', 'pro', 'enterprise'
  final bool adFreeEnabled;
  final int readingStreakDays;
  final int articlesReadCount;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.role = 'user',
    required this.createdAt,
    this.preferences = const UserPreferences(),
    this.subscriptionTier = 'free',
    this.adFreeEnabled = false,
    this.readingStreakDays = 5,
    this.articlesReadCount = 42,
  });

  bool get isPro => subscriptionTier == 'pro' || subscriptionTier == 'enterprise';

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'role': role,
        'createdAt': createdAt.toIso8601String(),
        'preferences': preferences.toJson(),
        'subscriptionTier': subscriptionTier,
        'adFreeEnabled': adFreeEnabled,
        'readingStreakDays': readingStreakDays,
        'articlesReadCount': articlesReadCount,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        role: json['role'] as String? ?? 'user',
        createdAt: DateTime.parse(json['createdAt'] as String),
        preferences: json['preferences'] != null
            ? UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>)
            : const UserPreferences(),
        subscriptionTier: json['subscriptionTier'] as String? ?? 'free',
        adFreeEnabled: json['adFreeEnabled'] as bool? ?? false,
        readingStreakDays: json['readingStreakDays'] as int? ?? 5,
        articlesReadCount: json['articlesReadCount'] as int? ?? 42,
      );

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? role,
    DateTime? createdAt,
    UserPreferences? preferences,
    String? subscriptionTier,
    bool? adFreeEnabled,
    int? readingStreakDays,
    int? articlesReadCount,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      adFreeEnabled: adFreeEnabled ?? this.adFreeEnabled,
      readingStreakDays: readingStreakDays ?? this.readingStreakDays,
      articlesReadCount: articlesReadCount ?? this.articlesReadCount,
    );
  }
}
