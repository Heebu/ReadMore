import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use GET.');
  }

  final container = context.read<AppContainer>();
  final txt = container.seoService.generateRobotsTxt();

  return Response(
    body: txt,
    headers: {
      'Content-Type': 'text/plain; charset=utf-8',
      'Cache-Control': 'public, max-age=86400', // Cache for 24 hours
    },
  );
}
