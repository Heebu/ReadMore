import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context, String category) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use GET.');
  }

  // Clean trailing .xml if present
  final cleanCategory = category.replaceAll('.xml', '');

  final container = context.read<AppContainer>();
  final xml = container.seoService.generateRssFeed(category: cleanCategory);

  return Response(
    body: xml,
    headers: {
      'Content-Type': 'application/rss+xml; charset=utf-8',
      'Cache-Control': 'public, max-age=600',
    },
  );
}
