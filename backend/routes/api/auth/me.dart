import 'package:dart_frog/dart_frog.dart';
import 'package:news_models/news_models.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use GET.');
  }

  final user = context.read<User?>();
  if (user == null) {
    return Response.json(
      statusCode: 401,
      body: {'error': 'Unauthorized. Bearer token required in Authorization header.'},
    );
  }

  return Response.json(body: {'user': user.toJson()});
}
