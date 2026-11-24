import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:news_models/news_models.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use POST.');
  }

  final user = context.read<User?>();
  if (user == null) {
    return Response.json(
      statusCode: 401,
      body: {'error': 'Authentication required.'},
    );
  }

  final container = context.read<AppContainer>();
  final updatedUser = container.authService.toggleAdFree(user.id);

  return Response.json(
    body: {
      'message': 'Ad-free preference updated',
      'adFreeEnabled': updatedUser.adFreeEnabled,
      'user': updatedUser.toJson(),
    },
  );
}
