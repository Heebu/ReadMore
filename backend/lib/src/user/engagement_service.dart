import 'package:news_models/news_models.dart';
import '../auth/auth_service.dart';
import '../news/news_repository.dart';
import '../storage/database_service.dart';

/// Tracks user bookmarks, read later queue, reading progress, and implicit topic affinities
/// persisted in SQLite.
class EngagementService {
  final NewsRepository _newsRepo;
  final DatabaseService _db;
  final AuthService? _authService;

  EngagementService({
    required NewsRepository newsRepo,
    DatabaseService? db,
    AuthService? authService,
  })  : _newsRepo = newsRepo,
        _db = db ?? DatabaseService.inMemory(),
        _authService = authService;

  // --- Bookmarks & Read Later ---

  SavedArticleItem saveArticle({
    required String userId,
    required String articleId,
    bool isReadLater = false,
  }) {
    final existing = _db.getSavedArticles(userId, isReadLater: isReadLater);
    for (final item in existing) {
      if (item.articleId == articleId) return item;
    }

    final item = SavedArticleItem(
      id: 'saved_${DateTime.now().millisecondsSinceEpoch}_${articleId.hashCode}',
      userId: userId,
      articleId: articleId,
      isReadLater: isReadLater,
      savedAt: DateTime.now(),
    );

    _db.upsertSavedArticle(item);
    _newsRepo.incrementLikes(articleId);

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
    return _db.deleteSavedArticle(
      userId: userId,
      articleId: articleId,
      isReadLater: isReadLater,
    );
  }

  List<Article> getSavedArticles({
    required String userId,
    bool isReadLater = false,
    int limit = 20,
    int offset = 0,
  }) {
    final filtered = _db.getSavedArticles(userId, isReadLater: isReadLater);
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

  User? recordInteraction({
    required String userId,
    required String articleId,
    required InteractionType type,
    int dwellTimeSeconds = 0,
  }) {
    _db.insertInteraction(
      UserInteraction(
        id: 'act_${DateTime.now().microsecondsSinceEpoch}',
        userId: userId,
        articleId: articleId,
        type: type,
        dwellTimeSeconds: dwellTimeSeconds,
        createdAt: DateTime.now(),
      ),
    );

    User? updatedUser;
    if (type == InteractionType.click) {
      _newsRepo.incrementViews(articleId);
      if (userId != 'guest' && _authService != null) {
        updatedUser = _authService.recordArticleRead(userId);
      }
    } else if (type == InteractionType.dwell30s && userId != 'guest' && _authService != null) {
      updatedUser = _authService.recordArticleRead(userId);
    }
    return updatedUser;
  }

  /// Calculates user implicit topic affinity weights (0.0 to 1.0)
  Map<String, double> calculateTopicAffinities(String userId) {
    final interactions = _db.getInteractions(userId);
    if (interactions.isEmpty) return {};

    final categoryPoints = <String, double>{};
    var totalPoints = 0.0;

    for (final interaction in interactions) {
      final article = _newsRepo.getArticleById(interaction.articleId);
      if (article == null) continue;

      var points = 1.0;
      if (interaction.type == InteractionType.dwell30s || interaction.dwellTimeSeconds >= 30) {
        points = 3.0;
      } else if (interaction.type == InteractionType.like || interaction.type == InteractionType.bookmark) {
        points = 4.0;
      } else if (interaction.type == InteractionType.fewerStoriesLikeThis) {
        points = -5.0;
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
