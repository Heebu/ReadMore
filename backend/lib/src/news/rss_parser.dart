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
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ReadMoreBot/1.0',
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
    final rawTitle = _getElementText(item, 'title');
    final title = _cleanHtml(rawTitle);
    final link = _getElementText(item, 'link');
    if (title.isEmpty || link.isEmpty) return null;

    final rawDesc = _getElementText(item, 'description');
    final contentEncoded = _getElementText(item, 'content:encoded');
    final summaryText = _cleanHtml(rawDesc.isNotEmpty ? rawDesc : contentEncoded);
    final contentText = contentEncoded.isNotEmpty
        ? _cleanHtml(contentEncoded, preserveParagraphs: true)
        : _cleanHtml(rawDesc, preserveParagraphs: true);

    final pubDateStr = _getElementText(item, 'pubDate');
    final dcDateStr = _getElementText(item, 'dc:date');
    final publishedAt = _parseDateTime(pubDateStr.isNotEmpty ? pubDateStr : dcDateStr);

    final imageUrl = _extractImageUrl(item, rawDesc, contentEncoded);
    final tags = _extractTags(item);
    final slug = _slugify(title);
    final id = _generateId(link);
    final basisText = contentText.length > summaryText.length ? contentText : summaryText;
    final wordCount = basisText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final readTime = (wordCount / 180).ceil().clamp(1, 15);

    return Article(
      id: id,
      title: title,
      slug: slug,
      summary: summaryText.length > 320 ? '${summaryText.substring(0, 317)}...' : summaryText,
      content: contentText.isNotEmpty ? contentText : summaryText,
      originalUrl: link.trim(),
      imageUrl: imageUrl,
      source: feed.toSource(),
      category: feed.category,
      tags: tags,
      publishedAt: publishedAt,
      readTimeMinutes: readTime,
      isBreaking: _isBreaking(title),
      country: feed.country,
    );
  }

  Article? _parseAtomEntry(XmlElement entry, FeedDefinition feed) {
    final rawTitle = _getElementText(entry, 'title');
    final title = _cleanHtml(rawTitle);
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
    final summaryText = _cleanHtml(summaryRaw.isNotEmpty ? summaryRaw : contentRaw);
    final contentText = contentRaw.isNotEmpty
        ? _cleanHtml(contentRaw, preserveParagraphs: true)
        : _cleanHtml(summaryRaw, preserveParagraphs: true);

    final updatedStr = _getElementText(entry, 'updated');
    final publishedStr = _getElementText(entry, 'published');
    final publishedAt = _parseDateTime(publishedStr.isNotEmpty ? publishedStr : updatedStr);

    final imageUrl = _extractImageUrl(entry, summaryRaw, contentRaw);
    final tags = _extractTags(entry);
    final slug = _slugify(title);
    final id = _generateId(link);
    final basisText = contentText.length > summaryText.length ? contentText : summaryText;
    final wordCount = basisText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final readTime = (wordCount / 180).ceil().clamp(1, 15);

    return Article(
      id: id,
      title: title,
      slug: slug,
      summary: summaryText.length > 320 ? '${summaryText.substring(0, 317)}...' : summaryText,
      content: contentText.isNotEmpty ? contentText : summaryText,
      originalUrl: link.trim(),
      imageUrl: imageUrl,
      source: feed.toSource(),
      category: feed.category,
      tags: tags,
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

  List<String> _extractTags(XmlElement item) {
    final tags = <String>[];
    final seen = <String>{};
    try {
      for (final el in item.findElements('category')) {
        final raw = el.getAttribute('term') ?? el.innerText;
        final cleaned = _cleanHtml(raw);
        if (cleaned.isNotEmpty && cleaned.length <= 32) {
          final lower = cleaned.toLowerCase();
          if (seen.add(lower)) {
            tags.add(cleaned);
            if (tags.length >= 4) break;
          }
        }
      }
    } catch (_) {}
    return tags;
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

  static String cleanHtml(String html, {bool preserveParagraphs = false}) {
    return _cleanHtmlStatic(html, preserveParagraphs: preserveParagraphs);
  }

  String _cleanHtml(String html, {bool preserveParagraphs = false}) {
    return _cleanHtmlStatic(html, preserveParagraphs: preserveParagraphs);
  }

  static String _cleanHtmlStatic(String html, {bool preserveParagraphs = false}) {
    if (html.isEmpty) return '';

    var text = html;

    // Decode first pass in case feed double-encoded HTML tags (e.g. &lt;p&gt;)
    text = _decodeHtmlEntities(text);

    if (preserveParagraphs) {
      text = text.replaceAll(
        RegExp(r'<(?:br|hr)\s*/?>|</(?:p|div|li|h[1-6]|blockquote)>', caseSensitive: false),
        '\n\n',
      );
      text = text.replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '\n• ');
    } else {
      text = text.replaceAll(
        RegExp(r'<(?:br|hr)\s*/?>|</(?:p|div|li|h[1-6]|blockquote)>', caseSensitive: false),
        ' ',
      );
    }

    // Strip remaining HTML tags
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode entities again in case tags wrapped entities or nested entities existed
    text = _decodeHtmlEntities(text);

    // Normalize non-breaking spaces
    text = text.replaceAll('\u00A0', ' ');

    // Normalize whitespace
    if (preserveParagraphs) {
      text = text
          .replaceAll(RegExp(r'[ \t\r\f\v]+'), ' ')
          .replaceAll(RegExp(r' *\n *'), '\n')
          .replaceAll(RegExp(r'\n{3,}'), '\n\n')
          .trim();
    } else {
      text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    }

    // Clean up WordPress/RSS trailing truncation markers like "[...]", "[…]", "[ ]"
    text = text.replaceAll(RegExp(r'\s*\[\s*(?:…|\.{3})\s*\]'), '…');
    text = text.replaceAll(RegExp(r'\s*\[\s*\]\s*$'), '…');
    text = text.replaceAll(RegExp(r'\[\s*\]'), '');
    text = text.replaceAll(
      RegExp(r'\s*The post .+ appeared first on .+\.?\s*$', caseSensitive: false),
      '',
    );

    return text.trim();
  }

  /// Attempts to fetch richer multi-paragraph article text from [url] when an
  /// RSS feed only supplied a brief snippet. Fails fast and returns null if
  /// blocked, timed out, or no cleaner long-form content is found.
  Future<String?> fetchReadableContent(String url) async {
    try {
      final uri = Uri.tryParse(url.trim());
      if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return null;
      }
      final response = await _client.get(
        uri,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ReadMoreBot/1.0',
          'Accept': 'text/html,application/xhtml+xml',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode != 200) return null;
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('html') && !contentType.contains('xml')) {
        return null;
      }

      var html = utf8.decode(response.bodyBytes, allowMalformed: true);
      // Narrow to <article> or <main> if present to avoid header/footer chrome
      final articleMatch = RegExp(
        r'<article\b[^>]*>([\s\S]*?)</article>',
        caseSensitive: false,
      ).firstMatch(html);
      if (articleMatch != null && (articleMatch.group(1)?.length ?? 0) > 400) {
        html = articleMatch.group(1)!;
      } else {
        final mainMatch = RegExp(
          r'<main\b[^>]*>([\s\S]*?)</main>',
          caseSensitive: false,
        ).firstMatch(html);
        if (mainMatch != null && (mainMatch.group(1)?.length ?? 0) > 400) {
          html = mainMatch.group(1)!;
        }
      }

      // Remove script, style, nav, aside, footer, noscript blocks
      html = html.replaceAll(
        RegExp(
          r'<(script|style|nav|aside|footer|noscript|svg|form)[^>]*>[\s\S]*?</\1>',
          caseSensitive: false,
        ),
        '',
      );

      final paragraphs = <String>[];
      final pMatches = RegExp(r'<p\b[^>]*>([\s\S]*?)</p>', caseSensitive: false)
          .allMatches(html);
      for (final m in pMatches) {
        final rawP = m.group(1) ?? '';
        final cleaned = _cleanHtmlStatic(rawP);
        if (cleaned.length < 60) continue;
        final lower = cleaned.toLowerCase();
        if (lower.contains('cookie') && lower.contains('accept') ||
            lower.contains('all rights reserved') ||
            lower.contains('subscribe to read') ||
            lower.contains('sign up for our newsletter') ||
            lower.contains('javascript is disabled')) {
          continue;
        }
        paragraphs.add(cleaned);
        if (paragraphs.length >= 10) break;
      }

      if (paragraphs.length < 2) return null;
      final joined = paragraphs.join('\n\n');
      return joined.length >= 350 ? joined : null;
    } catch (_) {
      return null;
    }
  }

  static String _decodeHtmlEntities(String input) {
    if (!input.contains('&')) return input;

    const named = <String, String>{
      'amp': '&',
      'lt': '<',
      'gt': '>',
      'quot': '"',
      'apos': "'",
      'nbsp': ' ',
      'rsquo': '’',
      'lsquo': '‘',
      'rdquo': '”',
      'ldquo': '“',
      'sbquo': '‚',
      'bdquo': '„',
      'mdash': '—',
      'ndash': '–',
      'hellip': '…',
      'middot': '·',
      'bull': '•',
      'laquo': '«',
      'raquo': '»',
      'lsaquo': '‹',
      'rsaquo': '›',
      'copy': '©',
      'reg': '®',
      'trade': '™',
      'euro': '€',
      'pound': '£',
      'yen': '¥',
      'cent': '¢',
      'deg': '°',
      'plusmn': '±',
      'times': '×',
      'divide': '÷',
      'frac12': '½',
      'frac14': '¼',
      'frac34': '¾',
      'prime': '′',
      'Prime': '″',
      'thinsp': ' ',
      'ensp': ' ',
      'emsp': ' ',
      'aacute': 'á',
      'eacute': 'é',
      'iacute': 'í',
      'oacute': 'ó',
      'uacute': 'ú',
      'agrave': 'à',
      'egrave': 'è',
      'ccedil': 'ç',
      'ntilde': 'ñ',
      'ouml': 'ö',
      'uuml': 'ü',
      'auml': 'ä',
      'szlig': 'ß',
    };

    return input.replaceAllMapped(RegExp(r'&(#x[0-9a-fA-F]+|#\d+|[a-zA-Z0-9]+);'), (m) {
      final entity = m.group(1)!;
      if (entity.startsWith('#x') || entity.startsWith('#X')) {
        final code = int.tryParse(entity.substring(2), radix: 16);
        if (code != null && code > 0 && code <= 0x10FFFF) {
          return String.fromCharCode(code);
        }
        return m.group(0)!;
      }
      if (entity.startsWith('#')) {
        final code = int.tryParse(entity.substring(1));
        if (code != null && code > 0 && code <= 0x10FFFF) {
          return String.fromCharCode(code);
        }
        return m.group(0)!;
      }
      return named[entity] ?? named[entity.toLowerCase()] ?? m.group(0)!;
    });
  }

  static DateTime parseDate(String? dateStr) => _parseDateTimeStatic(dateStr);

  DateTime _parseDateTime(String? dateStr) => _parseDateTimeStatic(dateStr);

  static DateTime _parseDateTimeStatic(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) {
      return DateTime.now();
    }
    final raw = dateStr.trim();

    // 1. ISO 8601
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso.toLocal();

    // 2. RFC 822 / RFC 1123 (e.g. "Thu, 14 Apr 2022 10:15:00 +0000" or "25 Nov 2026 09:30:00 EST")
    final rfc = _tryParseRfc822(raw);
    if (rfc != null) return rfc.toLocal();

    return DateTime.now();
  }

  static DateTime? _tryParseRfc822(String input) {
    const months = <String, int>{
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };

    const tzOffsetsHours = <String, int>{
      'UTC': 0,
      'GMT': 0,
      'UT': 0,
      'Z': 0,
      'EST': -5,
      'EDT': -4,
      'CST': -6,
      'CDT': -5,
      'MST': -7,
      'MDT': -6,
      'PST': -8,
      'PDT': -7,
      'BST': 1,
      'CET': 1,
      'CEST': 2,
      'WAT': 1,
      'JST': 9,
    };

    final cleanedInput = input.replaceAll(RegExp(r'\s*\([^)]*\)\s*$'), '').trim();
    final regex = RegExp(
      r'^(?:[A-Za-z]{3,9},?\s+)?(\d{1,2})\s+([A-Za-z]{3,9})\s+(\d{2,4})(?:\s+(\d{1,2}):(\d{2})(?::(\d{2}))?)?(?:\s+([+-]\d{2}:?\d{2}|[A-Za-z]{1,5}))?$',
    );
    final match = regex.firstMatch(cleanedInput);
    if (match == null) return null;

    final day = int.tryParse(match.group(1)!);
    final monthStr = match.group(2)!.toLowerCase().substring(0, 3);
    final month = months[monthStr];
    var year = int.tryParse(match.group(3)!);
    final hour = int.tryParse(match.group(4) ?? '0') ?? 0;
    final minute = int.tryParse(match.group(5) ?? '0') ?? 0;
    final second = int.tryParse(match.group(6) ?? '0') ?? 0;
    final tz = match.group(7)?.toUpperCase();

    if (day == null || month == null || year == null) return null;
    if (year < 100) {
      year += year >= 70 ? 1900 : 2000;
    }

    var offsetMinutes = 0;
    if (tz != null) {
      if (tz.startsWith('+') || tz.startsWith('-')) {
        final cleanTz = tz.replaceAll(':', '');
        if (cleanTz.length == 5) {
          final sign = cleanTz.startsWith('-') ? -1 : 1;
          final tzHours = int.tryParse(cleanTz.substring(1, 3)) ?? 0;
          final tzMins = int.tryParse(cleanTz.substring(3, 5)) ?? 0;
          offsetMinutes = sign * (tzHours * 60 + tzMins);
        }
      } else if (tzOffsetsHours.containsKey(tz)) {
        offsetMinutes = tzOffsetsHours[tz]! * 60;
      }
    }

    final utc = DateTime.utc(year, month, day, hour, minute, second).subtract(
      Duration(minutes: offsetMinutes),
    );
    return utc;
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
