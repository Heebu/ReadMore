import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use GET.');
  }

  final params = context.request.uri.queryParameters;
  final category = params['category'];
  final country = params['country'];
  final city = params['city'];
  final source = params['source'];
  final tag = params['tag'];
  final sortBy = params['sortBy'] ?? params['sort'] ?? 'latest';
  final limit = int.tryParse(params['limit'] ?? '20') ?? 20;
  final offset = int.tryParse(params['offset'] ?? '0') ?? 0;

  final container = context.read<AppContainer>();
  final result = container.newsRepository.getArticlesWithTotal(
    category: category,
    country: country,
    city: city,
    source: source,
    tag: tag,
    sortBy: sortBy,
    limit: limit,
    offset: offset,
  );

  return Response.json(
    body: {
      'count': result.articles.length,
      'total': result.total,
      'offset': offset,
      'limit': limit,
      'hasMore': (offset + result.articles.length) < result.total,
      'category': category ?? 'all',
      'sortBy': sortBy,
      'articles': result.articles.map((a) => a.toJson()).toList(),
    },
  );
}
