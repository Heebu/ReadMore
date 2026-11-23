import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use GET.');
  }

  final limit = int.tryParse(context.request.uri.queryParameters['limit'] ?? '10') ?? 10;
  final container = context.read<AppContainer>();
  final articles = container.newsRepository.getTrending(limit: limit);

  return Response.json(
    body: {
      'count': articles.length,
      'trending': true,
      'articles': articles.map((a) => a.toJson()).toList(),
    },
  );
}
