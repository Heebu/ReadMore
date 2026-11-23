import 'package:dart_frog/dart_frog.dart';
import 'package:news_models/news_models.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use GET.');
  }

  final categories = NewsCategory.allCategories.map((c) => c.toJson()).toList();
  return Response.json(body: {'categories': categories});
}
