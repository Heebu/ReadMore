import 'package:news_models/news_models.dart';

/// Splits an article's body into clean, readable paragraphs for the Reader View.
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

  // If a long single block has multiple sentences, break into ~2-3 sentence paragraphs
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

/// Returns true when the article body appears to be a short syndicated RSS excerpt
/// rather than a full multi-paragraph dispatch.
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

/// Builds 3 dynamic, topic-accurate editorial takeaways derived from the article itself.
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

  // For rich multi-sentence articles (4+ sentences), distill distinct lead + closing insights
  if (sentences.length >= 4) {
    addUnique(sentences.first);
    addUnique(sentences[sentences.length ~/ 2]);
    if (article.tags.isNotEmpty) {
      addUnique('Key subjects & entities covered: ${article.tags.take(4).join(', ')}.');
    } else {
      addUnique(sentences.last);
    }
    return takeaways.take(3).toList();
  }

  // For concise RSS previews (1-3 sentences), avoid duplicating the entire body verbatim:
  // give lead insight + desk metadata + topic/continuation context.
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
    final tagList = article.tags.take(4).join(', ');
    addUnique('Key subjects & entities covered: $tagList.');
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
      if (ch == '“') {
        inDoubleQuote = true;
      } else {
        inDoubleQuote = !inDoubleQuote;
      }
      continue;
    }
    if (ch == '”') {
      inDoubleQuote = false;
      continue;
    }

    if ((ch == '.' || ch == '!' || ch == '?') && !inDoubleQuote) {
      // Include closing quote immediately following sentence punctuation (e.g. '.”')
      if (i + 1 < normalized.length && (normalized[i + 1] == '"' || normalized[i + 1] == '”')) {
        buffer.write(normalized[++i]);
      }

      // Look ahead for whitespace + capital/quote start
      if (i + 1 < normalized.length && normalized[i + 1] == ' ') {
        var nextIdx = i + 2;
        while (nextIdx < normalized.length && normalized[nextIdx] == ' ') {
          nextIdx++;
        }
        if (nextIdx < normalized.length) {
          final currentText = buffer.toString().trim();
          final lastWord = currentText.split(RegExp(r'\s+')).last.toLowerCase();
          if (ch == '.' && abbreviations.contains(lastWord)) {
            continue;
          }
          // Skip single-letter initials like "A." or "J."
          if (ch == '.' && RegExp(r'^[A-Za-z]\.$').hasMatch(lastWord)) {
            continue;
          }
          final nextChar = normalized[nextIdx];
          if (RegExp(r'[A-Z0-9“"‘\x27]').hasMatch(nextChar)) {
            if (currentText.isNotEmpty) {
              sentences.add(currentText);
            }
            buffer.clear();
            i = nextIdx - 1;
          }
        }
      }
    }
  }

  final tail = buffer.toString().trim();
  if (tail.isNotEmpty) {
    sentences.add(tail);
  }
  return sentences;
}

String _formatCategoryLabel(String category) {
  switch (category.toLowerCase()) {
    case 'top':
      return 'Top Global Headlines';
    case 'international':
      return 'World & International';
    case 'tech':
      return 'Technology';
    case 'business':
      return 'Business & Finance';
    case 'sports':
      return 'Sports';
    case 'entertainment':
      return 'Entertainment';
    case 'science':
      return 'Science & Environment';
    case 'gists':
      return 'Gists & Viral';
    case 'food':
      return 'Food & Dining';
    case 'lifestyle':
      return 'Lifestyle & Wellness';
    case 'local':
      return 'Local Bureau';
    default:
      if (category.isEmpty) return 'General Dispatch';
      return '${category[0].toUpperCase()}${category.substring(1)}';
  }
}
