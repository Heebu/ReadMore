import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use GET.');
  }

  final container = context.read<AppContainer>();
  final clusters = container.newsRepository.getClusters();

  return Response.json(
    body: {
      'count': clusters.length,
      'description': 'Google News style Full Coverage story clusters',
      'clusters': clusters.map((c) => c.toJson()).toList(),
    },
  );
}
