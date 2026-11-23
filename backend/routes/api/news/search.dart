import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use GET.');
  }

  final query = context.request.uri.queryParameters['q'] ?? '';
  final limit = int.tryParse(context.request.uri.queryParameters['limit'] ?? '20') ?? 20;

  final container = context.read<AppContainer>();
  final articles = container.newsRepository.search(query, limit: limit);

  return Response.json(
    body: {
      'query': query,
      'count': articles.length,
      'articles': articles.map((a) => a.toJson()).toList(),
    },
  );
}
