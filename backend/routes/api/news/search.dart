import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use GET.');
  }

  final params = context.request.uri.queryParameters;
  final query = params['q'] ?? params['query'] ?? '';
  final category = params['category'];
  final source = params['source'];
  final country = params['country'];
  final city = params['city'];
  final sortBy = params['sortBy'] ?? 'relevance';
  final limit = int.tryParse(params['limit'] ?? '20') ?? 20;
  final offset = int.tryParse(params['offset'] ?? '0') ?? 0;

  final container = context.read<AppContainer>();
  final result = container.newsRepository.searchWithTotal(
    query,
    category: category,
    source: source,
    country: country,
    city: city,
    sortBy: sortBy,
    limit: limit,
    offset: offset,
  );

  return Response.json(
    body: {
      'query': query,
      'count': result.articles.length,
      'total': result.total,
      'offset': offset,
      'limit': limit,
      'hasMore': (offset + result.articles.length) < result.total,
      'articles': result.articles.map((a) => a.toJson()).toList(),
    },
  );
}
