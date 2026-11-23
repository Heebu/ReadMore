import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context, String id) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use GET.');
  }

  final container = context.read<AppContainer>();
  final cluster = container.newsRepository.getClusterById(id);

  if (cluster == null) {
    return Response.json(statusCode: 404, body: {'error': 'Story cluster not found'});
  }

  return Response.json(body: {'cluster': cluster.toJson()});
}
