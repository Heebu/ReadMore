import 'package:backend/backend.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed. Use GET.');
  }

  final container = context.read<AppContainer>();
  final article = await container.newsRepository.getAndEnrichArticleById(id);

  if (article == null) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Article not found.'},
    );
  }

  // Increment view count
  container.newsRepository.incrementViews(article.id);
  final updatedArticle = container.newsRepository.getArticleById(article.id) ?? article;

  // Generate SEO Schema.org JSON-LD structured data and Meta Tags
  final jsonLd = container.seoService.generateJsonLd(updatedArticle);
  final metaTags = container.seoService.generateMetaTags(updatedArticle);

  return Response.json(
    body: {
      'article': updatedArticle.toJson(),
      'seo': {
        'schemaJsonLd': jsonLd,
        'metaTagsHtml': metaTags,
      },
    },
    headers: {
      'X-Robots-Tag': 'index, follow, max-image-preview:large',
      'Cache-Control': 'public, max-age=300, stale-while-revalidate=600',
    },
  );
}
