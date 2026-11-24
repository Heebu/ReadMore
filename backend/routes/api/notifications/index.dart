import 'dart:convert';
import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final container = context.read<AppContainer>();

  // GET: List notifications
  if (context.request.method == HttpMethod.get) {
    final list = container.newsRepository.getNotifications();
    return Response.json(
      body: {
        'count': list.length,
        'notifications': list.map((n) => n.toJson()).toList(),
      },
    );
  }

  // POST: Mark notification read
  if (context.request.method == HttpMethod.post) {
    final bodyStr = await context.request.body();
    final json = jsonDecode(bodyStr) as Map<String, dynamic>;
    final id = json['id'] as String?;

    if (id != null) {
      container.newsRepository.markNotificationRead(id);
    }

    return Response.json(body: {'message': 'Marked as read'});
  }

  return Response(statusCode: 405, body: 'Method Not Allowed.');
}
