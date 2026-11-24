import 'dart:convert';
import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use POST.');
  }

  final bodyStr = await context.request.body();
  final json = jsonDecode(bodyStr) as Map<String, dynamic>;
  final adId = json['adId'] as String?;

  if (adId == null || adId.isEmpty) {
    return Response.json(statusCode: 400, body: {'error': 'adId is required.'});
  }

  final container = context.read<AppContainer>();
  container.newsRepository.recordAdClick(adId);

  return Response.json(
    body: {
      'adId': adId,
      'status': 'recorded',
    },
  );
}
