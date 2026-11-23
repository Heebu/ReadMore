import 'dart:convert';
import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:news_models/news_models.dart';

Future<Response> onRequest(RequestContext context) async {
  final user = context.read<User?>();
  if (user == null) {
    return Response.json(
      statusCode: 401,
      body: {'error': 'Authentication required to manage Read Later.'},
    );
  }

  final container = context.read<AppContainer>();

  // GET: List user's Read Later articles
  if (context.request.method == HttpMethod.get) {
    final limit = int.tryParse(context.request.uri.queryParameters['limit'] ?? '20') ?? 20;
    final offset = int.tryParse(context.request.uri.queryParameters['offset'] ?? '0') ?? 0;

    final articles = container.engagementService.getSavedArticles(
      userId: user.id,
      isReadLater: true,
      limit: limit,
      offset: offset,
    );

    return Response.json(
      body: {
        'count': articles.length,
        'readLater': articles.map((a) => a.toJson()).toList(),
      },
    );
  }

  // POST: Add article to Read Later
  if (context.request.method == HttpMethod.post) {
    final bodyStr = await context.request.body();
    final json = jsonDecode(bodyStr) as Map<String, dynamic>;
    final articleId = json['articleId'] as String?;

    if (articleId == null || articleId.isEmpty) {
      return Response.json(statusCode: 400, body: {'error': 'articleId is required.'});
    }

    final item = container.engagementService.saveArticle(
      userId: user.id,
      articleId: articleId,
      isReadLater: true,
    );

    return Response.json(
      statusCode: 201,
      body: {
        'message': 'Article added to Read Later queue',
        'item': item.toJson(),
      },
    );
  }

  // DELETE: Remove article from Read Later
  if (context.request.method == HttpMethod.delete) {
    final articleId = context.request.uri.queryParameters['articleId'];
    if (articleId == null || articleId.isEmpty) {
      return Response.json(statusCode: 400, body: {'error': 'articleId query parameter is required.'});
    }

    final removed = container.engagementService.removeSavedArticle(
      userId: user.id,
      articleId: articleId,
      isReadLater: true,
    );

    return Response.json(
      body: {
        'message': removed ? 'Removed from Read Later' : 'Article not found in Read Later',
        'success': removed,
      },
    );
  }

  return Response(statusCode: 405, body: 'Method Not Allowed.');
}
