import 'dart:convert';
import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:news_models/news_models.dart';

Future<Response> onRequest(RequestContext context) async {
  final user = context.read<User?>();
  if (user == null) {
    return Response.json(
      statusCode: 401,
      body: {'error': 'Authentication required to manage preferences.'},
    );
  }

  final container = context.read<AppContainer>();

  // GET: Return current user preferences
  if (context.request.method == HttpMethod.get) {
    return Response.json(body: {'preferences': user.preferences.toJson()});
  }

  // PUT: Update user preferences
  if (context.request.method == HttpMethod.put) {
    final bodyStr = await context.request.body();
    final json = jsonDecode(bodyStr) as Map<String, dynamic>;

    final currentPrefs = user.preferences;
    final updatedPrefs = currentPrefs.copyWith(
      followedTopics: (json['followedTopics'] as List<dynamic>?)?.map((e) => e as String).toList(),
      mutedTopics: (json['mutedTopics'] as List<dynamic>?)?.map((e) => e as String).toList(),
      blockedSources: (json['blockedSources'] as List<dynamic>?)?.map((e) => e as String).toList(),
      locationCity: json['locationCity'] as String?,
      locationCountry: json['locationCountry'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      enableBreakingAlerts: json['enableBreakingAlerts'] as bool?,
      enableDailyBriefing: json['enableDailyBriefing'] as bool?,
    );

    final updatedUser = User(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      role: user.role,
      createdAt: user.createdAt,
      preferences: updatedPrefs,
    );

    container.authService.updateUser(updatedUser);

    return Response.json(
      body: {
        'message': 'Preferences updated successfully',
        'preferences': updatedPrefs.toJson(),
      },
    );
  }

  return Response(statusCode: 405, body: 'Method Not Allowed.');
}
