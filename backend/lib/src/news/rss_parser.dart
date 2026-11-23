import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:news_models/news_models.dart';
import 'package:xml/xml.dart';
import 'feed_catalog.dart';

/// Ingests, parses, and normalizes RSS 2.0 & Atom feeds into Article models
class RssParser {
  final http.Client _client;

  RssParser({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Article>> fetchFeed(FeedDefinition feed) async {
    try {
      final response = await _client.get(
        Uri.parse(feed.url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ReadMoreBot/1.0',
          'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        return [];
      }

      final body = utf8.decode(response.bodyBytes, allowMalformed: true);
      return parseXml(body, feed);
    } catch (_) {
      // In production, log error or report to telemetry
      return [];
    }
  }

  List<Article> parseXml(String xmlString, FeedDefinition feed) {
    try {
      final document = XmlDocument.parse(xmlString);
      final articles = <Article>[];

      // Check for standard RSS 2.0 items
      final rssItems = document.findAllElements('item');
      if (rssItems.isNotEmpty) {
        for (final item in rssItems) {
          final article = _parseRssItem(item, feed);
          if (article != null) articles.add(article);
        }
        return articles;
      }

      // Check for Atom 1.0 entries
      final atomEntries = document.findAllElements('entry');
      if (atomEntries.isNotEmpty) {
        for (final entry in atomEntries) {
          final article = _parseAtomEntry(entry, feed);
          if (article != null) articles.add(article);
        }
      }

      return articles;
    } catch (_) {
      return [];
    }
  }

  Article? _parseRssItem(XmlElement item, FeedDefinition feed) {
    final title = _getElementText(item, 'title');
    final link = _getElementText(item, 'link');
    if (title.isEmpty || link.isEmpty) return null;

    final rawDesc = _getElementText(item, 'description');
    final contentEncoded = _getElementText(item, 'content:encoded');
    final summary = _cleanHtml(rawDesc.isNotEmpty ? rawDesc : contentEncoded);

    final pubDateStr = _getElementText(item, 'pubDate');
    final publishedAt = _parseDateTime(pubDateStr);

    final imageUrl = _extractImageUrl(item, rawDesc, contentEncoded);
    final slug = _slugify(title);
    final id = _generateId(link);
    final wordCount = summary.split(RegExp(r'\s+')).length;
    final readTime = (wordCount / 180).ceil().clamp(1, 15);

    return Article(
      id: id,
      title: title.trim(),
      slug: slug,
      summary: summary.length > 320 ? '${summary.substring(0, 317)}...' : summary,
      content: contentEncoded.isNotEmpty ? _cleanHtml(contentEncoded) : summary,
      originalUrl: link.trim(),
      imageUrl: imageUrl,
      source: feed.toSource(),
      category: feed.category,
      publishedAt: publishedAt,
      readTimeMinutes: readTime,
      isBreaking: _isBreaking(title),
      country: feed.country,
    );
  }

  Article? _parseAtomEntry(XmlElement entry, FeedDefinition feed) {
    final title = _getElementText(entry, 'title');
    var link = '';
    final linkElements = entry.findElements('link');
    for (final l in linkElements) {
      final href = l.getAttribute('href');
      final rel = l.getAttribute('rel');
      if (href != null && (rel == null || rel == 'alternate')) {
        link = href;
        break;
      }
    }
    if (title.isEmpty || link.isEmpty) return null;

    final summaryRaw = _getElementText(entry, 'summary');
    final contentRaw = _getElementText(entry, 'content');
    final summary = _cleanHtml(summaryRaw.isNotEmpty ? summaryRaw : contentRaw);

    final updatedStr = _getElementText(entry, 'updated');
    final publishedStr = _getElementText(entry, 'published');
    final publishedAt = _parseDateTime(publishedStr.isNotEmpty ? publishedStr : updatedStr);

    final imageUrl = _extractImageUrl(entry, summaryRaw, contentRaw);
    final slug = _slugify(title);
    final id = _generateId(link);
    final wordCount = summary.split(RegExp(r'\s+')).length;
    final readTime = (wordCount / 180).ceil().clamp(1, 15);

    return Article(
      id: id,
      title: title.trim(),
      slug: slug,
      summary: summary.length > 320 ? '${summary.substring(0, 317)}...' : summary,
      content: contentRaw.isNotEmpty ? _cleanHtml(contentRaw) : summary,
      originalUrl: link.trim(),
      imageUrl: imageUrl,
      source: feed.toSource(),
      category: feed.category,
      publishedAt: publishedAt,
      readTimeMinutes: readTime,
      isBreaking: _isBreaking(title),
      country: feed.country,
    );
  }

  String _getElementText(XmlElement parent, String tagName) {
    try {
      final matches = parent.findElements(tagName);
      if (matches.isNotEmpty) {
        return matches.first.innerText.trim();
      }
    } catch (_) {}
    return '';
  }

  String? _extractImageUrl(XmlElement item, String rawDesc, String content) {
    // 1. Check enclosure tag
    try {
      final enclosure = item.findElements('enclosure').firstOrNull;
      if (enclosure != null) {
        final url = enclosure.getAttribute('url');
        final type = enclosure.getAttribute('type');
        if (url != null && (type == null || type.startsWith('image/'))) {
          return url;
        }
      }
    } catch (_) {}

    // 2. Check media:content or media:thumbnail
    try {
      for (final mediaTag in ['media:content', 'media:thumbnail']) {
        final el = item.findElements(mediaTag).firstOrNull;
        if (el != null) {
          final url = el.getAttribute('url');
          if (url != null && url.isNotEmpty) return url;
        }
      }
    } catch (_) {}

    // 3. Fallback to extracting <img> src from raw HTML
    final html = '$rawDesc $content';
    final imgMatch = RegExp('<img[^>]+src=["\']([^"\']+)["\']', caseSensitive: false).firstMatch(html);
    if (imgMatch != null && imgMatch.groupCount >= 1) {
      final src = imgMatch.group(1);
      if (src != null && src.startsWith('http')) {
        return src;
      }
    }

    return null;
  }

  String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  DateTime _parseDateTime(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) {
      return DateTime.now();
    }
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      try {
        // RFC 822 / 1123 parsing fallback
        return DateTime.parse(
          HttpDate.parse(dateStr).toIso8601String(),
        );
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  String _slugify(String text) {
    final cleaned = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
    return cleaned.length > 80 ? cleaned.substring(0, 80) : cleaned;
  }

  String _generateId(String url) {
    final digest = md5.convert(utf8.encode(url));
    return 'art_${digest.toString().substring(0, 16)}';
  }

  bool _isBreaking(String title) {
    final lower = title.toLowerCase();
    return lower.contains('breaking:') ||
        lower.contains('urgent:') ||
        lower.contains('just in:') ||
        lower.contains('alert:');
  }
}

class HttpDate {
  static DateTime parse(String date) {
    // Quick fallback
    return DateTime.tryParse(date) ?? DateTime.now();
  }
}
