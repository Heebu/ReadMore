import 'package:news_models/news_models.dart';

/// Splits an article's body into clean, readable paragraphs for the Broadsheet Reader.
List<String> splitArticleParagraphs(Article article) {
  final raw = (article.content?.trim().isNotEmpty == true)
      ? article.content!.trim()
      : article.summary.trim();
  if (raw.isEmpty) {
    return article.title.trim().isNotEmpty ? [article.title.trim()] : const [];
  }

  final parts = raw
      .split(RegExp(r'\n\s*\n+'))
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();

  if (parts.length > 1) return parts;

  final sentences = _splitSentences(raw);
  if (sentences.length >= 4) {
    final grouped = <String>[];
    for (var i = 0; i < sentences.length; i += 2) {
      final end = (i + 2 <= sentences.length) ? i + 2 : sentences.length;
      grouped.add(sentences.sublist(i, end).join(' '));
    }
    return grouped;
  }

  return parts;
}

/// Returns true when the article body appears to be a short syndicated excerpt.
bool isArticleExcerpt(Article article) {
  final body = (article.content ?? article.summary).trim();
  if (body.isEmpty) return true;
  if (body.endsWith('…') || body.endsWith('...')) return true;
  final isExternal = article.originalUrl.startsWith('http') &&
      !article.originalUrl.contains('readmore.news');
  final hasMultipleParagraphs = body.contains('\n\n') && body.length >= 420;
  if (isExternal) {
    return !hasMultipleParagraphs && body.length < 650;
  }
  return !hasMultipleParagraphs && body.length < 420;
}

/// Builds 3 dynamic editorial takeaways derived directly from the article.
List<String> buildArticleTakeaways(Article article) {
  final body = (article.content?.trim().isNotEmpty == true)
      ? article.content!.trim()
      : article.summary.trim();

  final sentences = _splitSentences(body)
      .where((s) => s.length >= 25)
      .where((s) => !s.endsWith('…') && !s.endsWith('...'))
      .toList();

  final takeaways = <String>[];
  final seen = <String>{};

  void addUnique(String text) {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return;
    final norm = cleaned.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (seen.add(norm)) {
      takeaways.add(cleaned);
    }
  }

  if (sentences.length >= 4) {
    addUnique(sentences.first);
    addUnique(sentences[sentences.length ~/ 2]);
    if (article.tags.isNotEmpty) {
      addUnique(
        'Key subjects & entities covered: ${article.tags.take(4).join(', ')}.',
      );
    } else {
      addUnique(sentences.last);
    }
    return takeaways.take(3).toList();
  }

  if (sentences.isNotEmpty) {
    addUnique(sentences.first);
  } else if (article.summary.trim().isNotEmpty) {
    addUnique(article.summary.trim());
  } else {
    addUnique(article.title.trim());
  }

  final catLabel = _formatCategoryLabel(article.category);
  final locationHint = (article.city != null && article.city!.isNotEmpty)
      ? ' with local focus on ${article.city}'
      : (article.country != null &&
              article.country!.isNotEmpty &&
              article.country!.toLowerCase() != 'global')
          ? ' (${article.country})'
          : '';
  addUnique(
    'Filed by ${article.source.name} under $catLabel$locationHint (${article.readTimeMinutes} min read).',
  );

  if (article.tags.isNotEmpty) {
    addUnique(
      'Key subjects & entities covered: ${article.tags.take(4).join(', ')}.',
    );
  } else {
    addUnique(
      'Full reporting and primary documentation available directly via ${article.source.name}.',
    );
  }

  return takeaways.take(3).toList();
}

List<String> _splitSentences(String text) {
  final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty) return const [];

  const abbreviations = {
    'u.s.', 'u.k.', 'e.u.', 'u.n.', 'dr.', 'mr.', 'mrs.', 'ms.',
    'prof.', 'sr.', 'jr.', 'st.', 'no.', 'vol.', 'inc.', 'ltd.',
    'vs.', 'e.g.', 'i.e.', 'etc.', 'jan.', 'feb.', 'mar.', 'apr.',
    'aug.', 'sept.', 'oct.', 'nov.', 'dec.',
  };

  final sentences = <String>[];
  final buffer = StringBuffer();
  var inDoubleQuote = false;

  for (var i = 0; i < normalized.length; i++) {
    final ch = normalized[i];
    buffer.write(ch);

    if (ch == '"' || ch == '“') {
      inDoubleQuote = ch == '“' ? true : !inDoubleQuote;
      continue;
    }
    if (ch == '”') {
      inDoubleQuote = false;
      continue;
    }

    if ((ch == '.' || ch == '!' || ch == '?') && !inDoubleQuote) {
      var cursor = i + 1;
      while (cursor < normalized.length &&
          (normalized[cursor] == '"' || normalized[cursor] == '”')) {
        buffer.write(normalized[cursor]);
        cursor++;
      }
      final atEnd = cursor >= normalized.length;
      final followedBySpaceCapital = cursor < normalized.length &&
          normalized[cursor] == ' ' &&
          cursor + 1 < normalized.length &&
          RegExp(r'[A-Z0-9“"‘\x27]').hasMatch(normalized[cursor + 1]);

      if (atEnd || followedBySpaceCapital) {
        final current = buffer.toString().trim();
        final lastTokenMatch = RegExp(r'([A-Za-z.]+)$').firstMatch(current);
        final lastToken = lastTokenMatch?.group(1)?.toLowerCase() ?? '';
        if (ch == '.' && abbreviations.contains(lastToken)) {
          i = cursor - 1;
          continue;
        }
        if (current.isNotEmpty) {
          sentences.add(current);
          buffer.clear();
        }
        i = cursor;
      }
    }
  }

  final tail = buffer.toString().trim();
  if (tail.isNotEmpty) {
    sentences.add(tail);
  }
  return sentences;
}

String _formatCategoryLabel(String slug) {
  switch (slug.toLowerCase()) {
    case 'top':
      return 'Top Stories';
    case 'for_you':
    case 'for-you':
      return 'For You';
    case 'tech':
      return 'Technology';
    case 'business':
      return 'Business & Markets';
    case 'sports':
      return 'Sports';
    case 'entertainment':
      return 'Entertainment';
    case 'science':
      return 'Science';
    case 'food':
      return 'Food & Dining';
    case 'lifestyle':
      return 'Lifestyle';
    case 'gists':
      return 'Trending & Culture';
    case 'local':
      return 'Local Dispatch';
    default:
      if (slug.isEmpty) return 'General News';
      return slug[0].toUpperCase() + slug.substring(1);
  }
}
