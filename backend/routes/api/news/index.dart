import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use GET.');
  }

  final params = context.request.uri.queryParameters;
  final category = params['category'];
  final country = params['country'];
  final limit = int.tryParse(params['limit'] ?? '20') ?? 20;
  final offset = int.tryParse(params['offset'] ?? '0') ?? 0;

  final container = context.read<AppContainer>();
  final articles = container.newsRepository.getArticles(
    category: category,
    country: country,
    limit: limit,
    offset: offset,
  );

  return Response.json(
    body: {
      'count': articles.length,
      'offset': offset,
      'limit': limit,
      'category': category ?? 'all',
      'articles': articles.map((a) => a.toJson()).toList(),
    },
  );
}
