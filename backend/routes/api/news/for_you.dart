import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:news_models/news_models.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use GET.');
  }

  final container = context.read<AppContainer>();
  final user = context.read<User?>();
  final params = context.request.uri.queryParameters;
  final limit = int.tryParse(params['limit'] ?? '25') ?? 25;
  final offset = int.tryParse(params['offset'] ?? '0') ?? 0;

  // Build preferences from logged in user or query param hints (for guests)
  UserPreferences prefs;
  String? userId;

  if (user != null) {
    userId = user.id;
    prefs = user.preferences;
  } else {
    // Guest personalization
    final queryTopics = params['topics']?.split(',').map((e) => e.trim()).toList();
    final queryCity = params['city'];
    final queryCountry = params['country'];

    prefs = UserPreferences(
      followedTopics: queryTopics ?? const ['top', 'tech', 'entertainment'],
      locationCity: queryCity,
      locationCountry: queryCountry,
    );
  }

  final articles = container.recommendationEngine.getForYouFeed(
    preferences: prefs,
    userId: userId,
    limit: limit,
    offset: offset,
  );

  return Response.json(
    body: {
      'count': articles.length,
      'isPersonalized': true,
      'user': userId != null ? 'authenticated' : 'guest',
      'followedTopics': prefs.followedTopics,
      'articles': articles.map((a) => a.toJson()).toList(),
    },
  );
}
