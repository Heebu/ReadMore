import 'package:news_models/news_models.dart';
import '../news/news_repository.dart';

/// Tracks user bookmarks, read later queue, and implicit topic affinities
class EngagementService {
  final NewsRepository _newsRepo;
  final Map<String, List<SavedArticleItem>> _userSavedItems = {}; // userId -> list
  final Map<String, List<UserInteraction>> _userInteractions = {}; // userId -> list

  EngagementService({required NewsRepository newsRepo}) : _newsRepo = newsRepo;

  // --- Bookmarks & Read Later ---

  SavedArticleItem saveArticle({
    required String userId,
    required String articleId,
    bool isReadLater = false,
  }) {
    final list = _userSavedItems.putIfAbsent(userId, () => []);
    
    // Check if already saved
    final existingIndex = list.indexWhere((item) => item.articleId == articleId && item.isReadLater == isReadLater);
    if (existingIndex != -1) {
      return list[existingIndex];
    }

    final item = SavedArticleItem(
      id: 'saved_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      articleId: articleId,
      isReadLater: isReadLater,
      savedAt: DateTime.now(),
    );

    list.insert(0, item);

    // Update article metrics
    _newsRepo.incrementLikes(articleId);

    // Record interaction
    recordInteraction(
      userId: userId,
      articleId: articleId,
      type: isReadLater ? InteractionType.readLater : InteractionType.bookmark,
    );

    return item;
  }

  bool removeSavedArticle({
    required String userId,
    required String articleId,
    bool isReadLater = false,
  }) {
    final list = _userSavedItems[userId];
    if (list == null) return false;

    final initialLen = list.length;
    list.removeWhere((item) => item.articleId == articleId && item.isReadLater == isReadLater);
    return list.length < initialLen;
  }

  List<Article> getSavedArticles({
    required String userId,
    bool isReadLater = false,
    int limit = 20,
    int offset = 0,
  }) {
    final list = _userSavedItems[userId] ?? [];
    final filtered = list.where((item) => item.isReadLater == isReadLater).toList();

    final articles = <Article>[];
    for (final item in filtered) {
      final art = _newsRepo.getArticleById(item.articleId);
      if (art != null) articles.add(art);
    }

    if (offset >= articles.length) return [];
    final end = (offset + limit).clamp(0, articles.length);
    return articles.sublist(offset, end);
  }

  // --- Interaction Telemetry ---

  void recordInteraction({
    required String userId,
    required String articleId,
    required InteractionType type,
    int dwellTimeSeconds = 0,
  }) {
    final list = _userInteractions.putIfAbsent(userId, () => []);
    list.add(UserInteraction(
      id: 'act_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      articleId: articleId,
      type: type,
      dwellTimeSeconds: dwellTimeSeconds,
      createdAt: DateTime.now(),
    ));

    if (type == InteractionType.click) {
      _newsRepo.incrementViews(articleId);
    }
  }

  /// Calculates user implicit topic affinity weights (0.0 to 1.0)
  /// Articles where dwell >= 30s give high signal
  Map<String, double> calculateTopicAffinities(String userId) {
    final interactions = _userInteractions[userId];
    if (interactions == null || interactions.isEmpty) return {};

    final categoryPoints = <String, double>{};
    var totalPoints = 0.0;

    for (final interaction in interactions) {
      final article = _newsRepo.getArticleById(interaction.articleId);
      if (article == null) continue;

      var points = 1.0; // Click
      if (interaction.type == InteractionType.dwell30s || interaction.dwellTimeSeconds >= 30) {
        points = 3.0; // Deep read
      } else if (interaction.type == InteractionType.like || interaction.type == InteractionType.bookmark) {
        points = 4.0; // High intent
      } else if (interaction.type == InteractionType.fewerStoriesLikeThis) {
        points = -5.0; // Negative feedback
      }

      final cat = article.category.toLowerCase();
      categoryPoints[cat] = (categoryPoints[cat] ?? 0.0) + points;
      if (points > 0) totalPoints += points;
    }

    if (totalPoints <= 0) return {};

    final normalized = <String, double>{};
    categoryPoints.forEach((cat, pts) {
      normalized[cat] = (pts / totalPoints).clamp(0.0, 1.0);
    });

    return normalized;
  }
}
