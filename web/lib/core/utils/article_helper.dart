import 'package:news_models/news_models.dart';

/// Splits an article's body into clean, readable paragraphs for the Reader View.
List<String> splitArticleParagraphs(Article article) {
  final raw = (article.content?.trim().isNotEmpty == true)
      ? article.content!.trim()
      : article.summary.trim();
  if (raw.isEmpty) return const [];

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
  final hasMultipleParagraphs = body.contains('\n\n') && body.length >= 260;
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

  for (final s in sentences) {
    final norm = s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (seen.add(norm)) {
      takeaways.add(s);
      if (takeaways.length >= 3) break;
    }
  }

  // If the RSS item only had 1-2 short sentences, supplement with factual dispatch context
  if (takeaways.isEmpty && article.summary.trim().isNotEmpty) {
    takeaways.add(article.summary.trim());
  }

  if (takeaways.length < 2) {
    final catLabel = _formatCategoryLabel(article.category);
    final locationHint = (article.city != null && article.city!.isNotEmpty)
        ? ' with local focus on ${article.city}'
        : '';
    takeaways.add(
      'Filed by ${article.source.name} under $catLabel$locationHint (${article.readTimeMinutes} min read).',
    );
  }

  if (takeaways.length < 3) {
    if (article.tags.isNotEmpty) {
      final tagList = article.tags.take(4).join(', ');
      takeaways.add('Key subjects & entities covered: $tagList.');
    } else {
      takeaways.add(
        'Full reporting and primary documentation available directly via ${article.source.name}.',
      );
    }
  }

  return takeaways.take(3).toList();
}

List<String> _splitSentences(String text) {
  final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty) return const [];
  return normalized
      .split(RegExp(r'(?<=[.!?])\s+(?=[A-Z0-9“"‘\x27])'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
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
