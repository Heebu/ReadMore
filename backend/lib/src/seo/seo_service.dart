import 'dart:convert';
import 'package:news_models/news_models.dart';
import '../news/news_repository.dart';

/// Enterprise Search Engine Optimization Service for News Platforms
/// Conforms to Google News, Google Discover, Schema.org NewsArticle, and OpenGraph standards.
class SeoService {
  final NewsRepository _newsRepo;
  final String baseUrl;
  final String siteName;

  SeoService({
    required NewsRepository newsRepo,
    this.baseUrl = 'https://readmore.news',
    this.siteName = 'ReadMore News',
  }) : _newsRepo = newsRepo;

  /// Generates robots.txt optimized for news crawlers (Googlebot, Googlebot-News, Bingbot)
  String generateRobotsTxt() {
    return '''
# ReadMore News Platform - Robots Directive
User-agent: *
Allow: /
Allow: /news/
Allow: /section/
Disallow: /api/auth/
Disallow: /api/user/
Disallow: /admin/

User-agent: Googlebot
Allow: /
Allow: /news/
Allow: /section/
Disallow: /api/auth/
Disallow: /api/user/

User-agent: Googlebot-News
Allow: /
Allow: /news/

# Official Sitemaps
Sitemap: $baseUrl/sitemap.xml
Sitemap: $baseUrl/sitemap_news.xml
'''.trim();
  }

  /// Generates a Google News compliant XML sitemap (<urlset> with <news:news>)
  /// Google requires news sitemaps to include articles published in the last 48 hours.
  String generateGoogleNewsSitemap() {
    final now = DateTime.now();
    final recentArticles = _newsRepo.getArticles(limit: 500).where((a) {
      return now.difference(a.publishedAt).inHours <= 48;
    }).toList();

    final buffer = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"')
      ..writeln('        xmlns:news="http://www.google.com/schemas/sitemap-news/0.9">');

    for (final article in recentArticles) {
      final articleUrl = '$baseUrl/news/${article.category}/${article.slug}-${article.id}';
      buffer
        ..writeln('  <url>')
        ..writeln('    <loc>${_escapeXml(articleUrl)}</loc>')
        ..writeln('    <news:news>')
        ..writeln('      <news:publication>')
        ..writeln('        <news:name>${_escapeXml(article.source.name)}</news:name>')
        ..writeln('        <news:language>en</news:language>')
        ..writeln('      </news:publication>')
        ..writeln('      <news:publication_date>${article.publishedAt.toIso8601String()}</news:publication_date>')
        ..writeln('      <news:title>${_escapeXml(article.title)}</news:title>')
        ..writeln('    </news:news>')
        ..writeln('  </url>');
    }

    buffer.writeln('</urlset>');
    return buffer.toString();
  }

  /// Generates a standard sitemap.xml indexing sections and articles
  String generateStandardSitemap() {
    final buffer = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">');

    // Index homepage
    buffer
      ..writeln('  <url>')
      ..writeln('    <loc>$baseUrl/</loc>')
      ..writeln('    <changefreq>always</changefreq>')
      ..writeln('    <priority>1.0</priority>')
      ..writeln('  </url>');

    // Index all 12 categories
    for (final cat in NewsCategory.allCategories) {
      buffer
        ..writeln('  <url>')
        ..writeln('    <loc>$baseUrl/section/${cat.slug}</loc>')
        ..writeln('    <changefreq>hourly</changefreq>')
        ..writeln('    <priority>0.8</priority>')
        ..writeln('  </url>');
    }

    // Index latest articles
    final articles = _newsRepo.getArticles(limit: 200);
    for (final article in articles) {
      final articleUrl = '$baseUrl/news/${article.category}/${article.slug}-${article.id}';
      buffer
        ..writeln('  <url>')
        ..writeln('    <loc>${_escapeXml(articleUrl)}</loc>')
        ..writeln('    <lastmod>${article.publishedAt.toIso8601String()}</lastmod>')
        ..writeln('    <changefreq>daily</changefreq>')
        ..writeln('    <priority>0.7</priority>')
        ..writeln('  </url>');
    }

    buffer.writeln('</urlset>');
    return buffer.toString();
  }

  /// Generates an outbound RSS 2.0 feed for content syndication & WebSub crawlers
  String generateRssFeed({String? category}) {
    final articles = _newsRepo.getArticles(category: category, limit: 50);
    final categoryObj = category != null ? NewsCategory.findBySlug(category) : null;
    final feedTitle = categoryObj != null ? '$siteName - ${categoryObj.name}' : siteName;
    final feedUrl = category != null ? '$baseUrl/rss/$category.xml' : '$baseUrl/rss.xml';

    final buffer = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln('<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/">')
      ..writeln('  <channel>')
      ..writeln('    <title>${_escapeXml(feedTitle)}</title>')
      ..writeln('    <link>$baseUrl</link>')
      ..writeln('    <description>Latest verified news stories and updates aggregated on ReadMore</description>')
      ..writeln('    <language>en-us</language>')
      ..writeln('    <atom:link href="$feedUrl" rel="self" type="application/rss+xml" />');

    for (final article in articles) {
      final articleUrl = '$baseUrl/news/${article.category}/${article.slug}-${article.id}';
      buffer
        ..writeln('    <item>')
        ..writeln('      <title>${_escapeXml(article.title)}</title>')
        ..writeln('      <link>${_escapeXml(articleUrl)}</link>')
        ..writeln('      <guid isPermaLink="false">${article.id}</guid>')
        ..writeln('      <pubDate>${article.publishedAt.toUtc().toIso8601String()}</pubDate>')
        ..writeln('      <description>${_escapeXml(article.summary)}</description>')
        ..writeln('      <category>${_escapeXml(article.category)}</category>');

      if (article.imageUrl != null) {
        buffer.writeln('      <media:content url="${_escapeXml(article.imageUrl!)}" medium="image" />');
      }

      buffer.writeln('    </item>');
    }

    buffer
      ..writeln('  </channel>')
      ..writeln('</rss>');

    return buffer.toString();
  }

  /// Generates full Schema.org NewsArticle JSON-LD structured data
  /// Compliant with Google Top Stories, Voice Search (Speakable), and Breadcrumbs
  Map<String, dynamic> generateJsonLd(Article article) {
    final articleUrl = '$baseUrl/news/${article.category}/${article.slug}-${article.id}';
    final categoryObj = NewsCategory.findBySlug(article.category);
    final categoryName = categoryObj?.name ?? article.category;

    return {
      '@context': 'https://schema.org',
      '@graph': [
        // 1. NewsArticle schema
        {
          '@type': 'NewsArticle',
          '@id': '$articleUrl#article',
          'isPartOf': {
            '@type': 'WebPage',
            '@id': articleUrl,
          },
          'headline': article.title.length > 110 ? article.title.substring(0, 107) + '...' : article.title,
          'alternativeHeadline': article.title,
          'description': article.summary,
          'inLanguage': 'en-US',
          'mainEntityOfPage': articleUrl,
          if (article.imageUrl != null)
            'image': [
              article.imageUrl,
            ],
          'datePublished': article.publishedAt.toIso8601String(),
          'dateModified': article.publishedAt.toIso8601String(),
          'author': [
            {
              '@type': 'Organization',
              'name': article.source.name,
              'url': 'https://${article.source.domain}',
            }
          ],
          'publisher': {
            '@type': 'NewsMediaOrganization',
            '@id': '$baseUrl/#organization',
            'name': siteName,
            'url': baseUrl,
            'logo': {
              '@type': 'ImageObject',
              'url': '$baseUrl/assets/logo.png',
              'width': 600,
              'height': 60,
            },
          },
          'articleSection': categoryName,
          'isAccessibleForFree': true,
          'wordCount': article.summary.split(' ').length,
          if (article.tags.isNotEmpty) 'keywords': article.tags,
          // Speakable specification for Google Assistant & Smart Speakers
          'speakable': {
            '@type': 'SpeakableSpecification',
            'cssSelector': ['.article-headline', '.article-summary'],
          },
        },
        // 2. BreadcrumbList schema
        {
          '@type': 'BreadcrumbList',
          '@id': '$articleUrl#breadcrumb',
          'itemListElement': [
            {
              '@type': 'ListItem',
              'position': 1,
              'name': 'Home',
              'item': baseUrl,
            },
            {
              '@type': 'ListItem',
              'position': 2,
              'name': categoryName,
              'item': '$baseUrl/section/${article.category}',
            },
            {
              '@type': 'ListItem',
              'position': 3,
              'name': article.title,
              'item': articleUrl,
            },
          ],
        },
      ],
    };
  }

  /// Generates complete HTML meta tag block for Web SSR and Social Crawlers
  /// Includes Google Discover `max-image-preview:large` and OpenGraph tags
  String generateMetaTags(Article article) {
    final articleUrl = '$baseUrl/news/${article.category}/${article.slug}-${article.id}';
    final image = article.imageUrl ?? '$baseUrl/assets/preview.png';

    return '''
<title>${_escapeXml(article.title)} | $siteName</title>
<meta name="description" content="${_escapeXml(article.summary)}" />
<link rel="canonical" href="$articleUrl" />

<!-- Google News & Discover Optimization Directives -->
<meta name="robots" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
<meta name="googlebot" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1" />
<meta name="googlebot-news" content="index, follow" />

<!-- Syndication Links -->
<link rel="alternate" type="application/rss+xml" title="$siteName RSS" href="$baseUrl/rss.xml" />
<link rel="alternate" type="application/rss+xml" title="$siteName (${article.category}) RSS" href="$baseUrl/rss/${article.category}.xml" />

<!-- OpenGraph / Facebook -->
<meta property="og:site_name" content="$siteName" />
<meta property="og:type" content="article" />
<meta property="og:url" content="$articleUrl" />
<meta property="og:title" content="${_escapeXml(article.title)}" />
<meta property="og:description" content="${_escapeXml(article.summary)}" />
<meta property="og:image" content="$image" />
<meta property="og:image:width" content="1200" />
<meta property="og:image:height" content="630" />
<meta property="article:published_time" content="${article.publishedAt.toIso8601String()}" />
<meta property="article:section" content="${article.category}" />

<!-- Twitter / X Cards -->
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:url" content="$articleUrl" />
<meta name="twitter:title" content="${_escapeXml(article.title)}" />
<meta name="twitter:description" content="${_escapeXml(article.summary)}" />
<meta name="twitter:image" content="$image" />

<!-- Structured Data: NewsArticle + BreadcrumbList -->
<script type="application/ld+json">
${jsonEncode(generateJsonLd(article))}
</script>
'''.trim();
  }

  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
