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

  const UserPreferences({
    this.followedTopics = const ['top', 'tech'],
    this.mutedTopics = const [],
    this.blockedSources = const [],
    this.favoriteSources = const [],
    this.preferredLanguage = 'en',
    this.locationCity,
    this.locationCountry,
    this.latitude,
    this.longitude,
    this.enableBreakingAlerts = true,
    this.enableDailyBriefing = true,
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
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) => UserPreferences(
        followedTopics: (json['followedTopics'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const ['top', 'tech'],
        mutedTopics: (json['mutedTopics'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
        blockedSources: (json['blockedSources'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
        favoriteSources: (json['favoriteSources'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
        preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
        locationCity: json['locationCity'] as String?,
        locationCountry: json['locationCountry'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        enableBreakingAlerts: json['enableBreakingAlerts'] as bool? ?? true,
        enableDailyBriefing: json['enableDailyBriefing'] as bool? ?? true,
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
    );
  }
}

/// User account entity
class User {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String role; // 'user', 'editor', 'admin'
  final DateTime createdAt;
  final UserPreferences preferences;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.role = 'user',
    required this.createdAt,
    this.preferences = const UserPreferences(),
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'role': role,
        'createdAt': createdAt.toIso8601String(),
        'preferences': preferences.toJson(),
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
      );
}
