import 'dart:convert';
import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:news_models/news_models.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final container = context.read<AppContainer>();

  // GET: Fetch comments for this article
  if (context.request.method == HttpMethod.get) {
    final comments = container.newsRepository.getComments(id);
    return Response.json(
      body: {
        'articleId': id,
        'count': comments.length,
        'comments': comments.map((c) => c.toJson()).toList(),
      },
    );
  }

  // POST: Add a new comment
  if (context.request.method == HttpMethod.post) {
    final bodyStr = await context.request.body();
    final json = jsonDecode(bodyStr) as Map<String, dynamic>;

    final user = context.read<User?>();
    final author = json['author'] as String? ?? user?.displayName ?? 'Anonymous Reader';
    final avatarUrl = json['avatarUrl'] as String? ??
        user?.avatarUrl ??
        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop';
    final text = (json['text'] as String?)?.trim() ?? '';

    if (text.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Comment text cannot be empty.'},
      );
    }

    final comment = container.newsRepository.addComment(
      id,
      author: author,
      avatarUrl: avatarUrl,
      text: text,
    );

    return Response.json(
      statusCode: 201,
      body: {
        'message': 'Comment posted successfully',
        'comment': comment.toJson(),
      },
    );
  }

  return Response(statusCode: 405, body: 'Method Not Allowed.');
}
