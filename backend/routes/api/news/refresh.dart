import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use POST.');
  }

  final container = context.read<AppContainer>();
  final newArticlesCount = await container.newsRepository.refreshAllFeeds();

  return Response.json(
    body: {
      'message': 'Feeds refreshed successfully',
      'newArticlesIngested': newArticlesCount,
      'totalArticlesInStore': container.newsRepository.getArticles(limit: 9999).length,
    },
  );
}
