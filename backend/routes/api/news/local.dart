import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:news_models/news_models.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use GET.');
  }

  final params = context.request.uri.queryParameters;
  final user = context.read<User?>();

  final city = params['city'] ?? user?.preferences.locationCity;
  final country = params['country'] ?? user?.preferences.locationCountry;
  final limit = int.tryParse(params['limit'] ?? '15') ?? 15;

  final container = context.read<AppContainer>();
  final articles = container.newsRepository.getLocalNews(
    city: city,
    country: country,
    limit: limit,
  );

  return Response.json(
    body: {
      'location': {
        'city': city ?? 'Detected Region',
        'country': country ?? 'Global',
      },
      'count': articles.length,
      'articles': articles.map((a) => a.toJson()).toList(),
    },
  );
}
