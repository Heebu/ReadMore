import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'name': 'ReadMore News Platform API',
      'version': '1.0.0',
      'status': 'online',
      'documentation': {
        'auth': ['/api/auth/register', '/api/auth/login', '/api/auth/me'],
        'news': [
          '/api/news',
          '/api/news/for_you',
          '/api/news/local',
          '/api/news/breaking',
          '/api/news/trending',
          '/api/news/search?q=...',
          '/api/news/clusters',
        ],
        'categories': '/api/categories',
        'user': [
          '/api/user/bookmarks',
          '/api/user/read_later',
          '/api/user/interaction',
          '/api/user/preferences',
        ],
        'widgets': ['/api/widgets/weather', '/api/widgets/markets', '/api/widgets/trending'],
        'seo': ['/sitemap.xml', '/sitemap_news.xml'],
      },
    },
  );
}
