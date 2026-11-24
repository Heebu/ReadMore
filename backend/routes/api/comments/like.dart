import 'dart:convert';
import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use POST.');
  }

  final bodyStr = await context.request.body();
  final json = jsonDecode(bodyStr) as Map<String, dynamic>;
  final commentId = json['commentId'] as String?;

  if (commentId == null || commentId.isEmpty) {
    return Response.json(statusCode: 400, body: {'error': 'commentId is required.'});
  }

  final container = context.read<AppContainer>();
  final isLiked = container.newsRepository.toggleCommentLike(commentId);

  return Response.json(
    body: {
      'commentId': commentId,
      'isLiked': isLiked,
      'message': isLiked ? 'Comment liked' : 'Comment unliked',
    },
  );
}
