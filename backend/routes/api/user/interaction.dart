import 'dart:convert';
import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:news_models/news_models.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use POST.');
  }

  final user = context.read<User?>();
  final bodyStr = await context.request.body();
  final json = jsonDecode(bodyStr) as Map<String, dynamic>;

  final articleId = json['articleId'] as String?;
  final typeStr = json['type'] as String?;
  final dwellTimeSeconds = (json['dwellTimeSeconds'] as num?)?.toInt() ?? 0;

  if (articleId == null || typeStr == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Missing articleId or type.'},
    );
  }

  final type = InteractionType.values.byName(typeStr);
  final userId = user?.id ?? json['guestId'] as String? ?? 'guest';

  final container = context.read<AppContainer>();
  container.engagementService.recordInteraction(
    userId: userId,
    articleId: articleId,
    type: type,
    dwellTimeSeconds: dwellTimeSeconds,
  );

  return Response.json(
    body: {
      'message': 'Interaction logged',
      'articleId': articleId,
      'type': type.name,
      'dwellTimeSeconds': dwellTimeSeconds,
    },
  );
}
