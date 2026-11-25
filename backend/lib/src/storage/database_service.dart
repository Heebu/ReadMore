import 'dart:convert';
import 'dart:io';
import 'package:news_models/news_models.dart';
import 'package:sqlite3/sqlite3.dart';

/// Persistent SQLite storage layer backing users, preferences, saved articles,
/// interaction telemetry, comments, ads, and password reset tokens.
class DatabaseService {
  final Database db;

  DatabaseService._(this.db) {
    _migrate();
  }

  /// Opens a persistent file-backed SQLite database (defaults to data/readmore.db).
  factory DatabaseService.open({String? dbPath}) {
    final resolvedPath = dbPath ??
        Platform.environment['READMORE_DB_PATH'] ??
        '${Directory.current.path}${Platform.pathSeparator}data${Platform.pathSeparator}readmore.db';
    final file = File(resolvedPath);
    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }
    return DatabaseService._(sqlite3.open(resolvedPath));
  }

  /// Opens an isolated in-memory SQLite database for tests.
  factory DatabaseService.inMemory() {
    return DatabaseService._(sqlite3.openInMemory());
  }

  void _migrate() {
    db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT,
        display_name TEXT NOT NULL,
        avatar_url TEXT,
        role TEXT NOT NULL DEFAULT 'user',
        created_at TEXT NOT NULL,
        preferences_json TEXT NOT NULL,
        subscription_tier TEXT NOT NULL DEFAULT 'free',
        ad_free_enabled INTEGER NOT NULL DEFAULT 0,
        reading_streak_days INTEGER NOT NULL DEFAULT 1,
        articles_read_count INTEGER NOT NULL DEFAULT 0,
        last_active_date TEXT
      );

      CREATE TABLE IF NOT EXISTS saved_articles (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        article_id TEXT NOT NULL,
        is_read_later INTEGER NOT NULL DEFAULT 0,
        saved_at TEXT NOT NULL,
        UNIQUE(user_id, article_id, is_read_later)
      );

      CREATE TABLE IF NOT EXISTS user_interactions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        article_id TEXT NOT NULL,
        type TEXT NOT NULL,
        dwell_time_seconds INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS article_comments (
        id TEXT PRIMARY KEY,
        article_id TEXT NOT NULL,
        author TEXT NOT NULL,
        avatar_url TEXT NOT NULL,
        text TEXT NOT NULL,
        time_ago TEXT NOT NULL,
        created_at TEXT NOT NULL,
        likes INTEGER NOT NULL DEFAULT 0
      );

      CREATE TABLE IF NOT EXISTS sponsored_ads (
        id TEXT PRIMARY KEY,
        payload_json TEXT NOT NULL,
        impressions INTEGER NOT NULL DEFAULT 0,
        clicks INTEGER NOT NULL DEFAULT 0
      );

      CREATE TABLE IF NOT EXISTS password_reset_tokens (
        token TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        expires_at TEXT NOT NULL
      );
    ''');
  }

  // =========================================================================
  // USERS & AUTH PERSISTENCE
  // =========================================================================

  ({User user, String? passwordHash, String? lastActiveDate})? getUserRecordByEmail(String email) {
    final rows = db.select(
      'SELECT * FROM users WHERE LOWER(email) = LOWER(?) LIMIT 1',
      [email.trim()],
    );
    if (rows.isEmpty) return null;
    return _rowToUserRecord(rows.first);
  }

  ({User user, String? passwordHash, String? lastActiveDate})? getUserRecordById(String userId) {
    final rows = db.select('SELECT * FROM users WHERE id = ? LIMIT 1', [userId]);
    if (rows.isEmpty) return null;
    return _rowToUserRecord(rows.first);
  }

  void upsertUser(User user, {String? passwordHash, String? lastActiveDate}) {
    final existing = getUserRecordById(user.id);
    final effectiveHash = passwordHash ?? existing?.passwordHash;
    final effectiveDate = lastActiveDate ?? existing?.lastActiveDate;

    db.execute(
      '''
      INSERT INTO users (
        id, email, password_hash, display_name, avatar_url, role, created_at,
        preferences_json, subscription_tier, ad_free_enabled,
        reading_streak_days, articles_read_count, last_active_date
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        email = excluded.email,
        password_hash = COALESCE(excluded.password_hash, users.password_hash),
        display_name = excluded.display_name,
        avatar_url = excluded.avatar_url,
        role = excluded.role,
        preferences_json = excluded.preferences_json,
        subscription_tier = excluded.subscription_tier,
        ad_free_enabled = excluded.ad_free_enabled,
        reading_streak_days = excluded.reading_streak_days,
        articles_read_count = excluded.articles_read_count,
        last_active_date = COALESCE(excluded.last_active_date, users.last_active_date)
      ''',
      [
        user.id,
        user.email.trim().toLowerCase(),
        effectiveHash,
        user.displayName,
        user.avatarUrl,
        user.role,
        user.createdAt.toIso8601String(),
        jsonEncode(user.preferences.toJson()),
        user.subscriptionTier,
        user.adFreeEnabled ? 1 : 0,
        user.readingStreakDays,
        user.articlesReadCount,
        effectiveDate,
      ],
    );
  }

  void updatePasswordHash(String userId, String passwordHash) {
    db.execute('UPDATE users SET password_hash = ? WHERE id = ?', [passwordHash, userId]);
  }

  void saveResetToken(String token, String userId, DateTime expiresAt) {
    db.execute(
      'INSERT OR REPLACE INTO password_reset_tokens (token, user_id, expires_at) VALUES (?, ?, ?)',
      [token, userId, expiresAt.toIso8601String()],
    );
  }

  ({String userId, DateTime expiresAt})? consumeResetToken(String token) {
    final rows = db.select(
      'SELECT user_id, expires_at FROM password_reset_tokens WHERE token = ? LIMIT 1',
      [token],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    db.execute('DELETE FROM password_reset_tokens WHERE token = ?', [token]);
    return (
      userId: row['user_id'] as String,
      expiresAt: DateTime.parse(row['expires_at'] as String),
    );
  }

  ({User user, String? passwordHash, String? lastActiveDate}) _rowToUserRecord(Row row) {
    final prefsMap = jsonDecode(row['preferences_json'] as String) as Map<String, dynamic>;
    final user = User(
      id: row['id'] as String,
      email: row['email'] as String,
      displayName: row['display_name'] as String,
      avatarUrl: row['avatar_url'] as String?,
      role: row['role'] as String? ?? 'user',
      createdAt: DateTime.parse(row['created_at'] as String),
      preferences: UserPreferences.fromJson(prefsMap),
      subscriptionTier: row['subscription_tier'] as String? ?? 'free',
      adFreeEnabled: (row['ad_free_enabled'] as int? ?? 0) == 1,
      readingStreakDays: row['reading_streak_days'] as int? ?? 1,
      articlesReadCount: row['articles_read_count'] as int? ?? 0,
    );
    return (
      user: user,
      passwordHash: row['password_hash'] as String?,
      lastActiveDate: row['last_active_date'] as String?,
    );
  }

  // =========================================================================
  // SAVED ARTICLES & TELEMETRY
  // =========================================================================

  void upsertSavedArticle(SavedArticleItem item) {
    db.execute(
      '''
      INSERT OR IGNORE INTO saved_articles (id, user_id, article_id, is_read_later, saved_at)
      VALUES (?, ?, ?, ?, ?)
      ''',
      [
        item.id,
        item.userId,
        item.articleId,
        item.isReadLater ? 1 : 0,
        item.savedAt.toIso8601String(),
      ],
    );
  }

  bool deleteSavedArticle({
    required String userId,
    required String articleId,
    required bool isReadLater,
  }) {
    db.execute(
      'DELETE FROM saved_articles WHERE user_id = ? AND article_id = ? AND is_read_later = ?',
      [userId, articleId, isReadLater ? 1 : 0],
    );
    return db.updatedRows > 0;
  }

  List<SavedArticleItem> getSavedArticles(String userId, {required bool isReadLater}) {
    final rows = db.select(
      'SELECT * FROM saved_articles WHERE user_id = ? AND is_read_later = ? ORDER BY saved_at DESC',
      [userId, isReadLater ? 1 : 0],
    );
    return rows
        .map(
          (r) => SavedArticleItem(
            id: r['id'] as String,
            userId: r['user_id'] as String,
            articleId: r['article_id'] as String,
            isReadLater: (r['is_read_later'] as int? ?? 0) == 1,
            savedAt: DateTime.parse(r['saved_at'] as String),
          ),
        )
        .toList();
  }

  void insertInteraction(UserInteraction interaction) {
    db.execute(
      '''
      INSERT INTO user_interactions (id, user_id, article_id, type, dwell_time_seconds, created_at)
      VALUES (?, ?, ?, ?, ?, ?)
      ''',
      [
        interaction.id,
        interaction.userId,
        interaction.articleId,
        interaction.type.name,
        interaction.dwellTimeSeconds,
        interaction.createdAt.toIso8601String(),
      ],
    );
  }

  List<UserInteraction> getInteractions(String userId) {
    final rows = db.select(
      'SELECT * FROM user_interactions WHERE user_id = ? ORDER BY created_at DESC LIMIT 200',
      [userId],
    );
    return rows
        .map(
          (r) => UserInteraction(
            id: r['id'] as String,
            userId: r['user_id'] as String,
            articleId: r['article_id'] as String,
            type: InteractionType.values.firstWhere(
              (t) => t.name == r['type'],
              orElse: () => InteractionType.click,
            ),
            dwellTimeSeconds: r['dwell_time_seconds'] as int? ?? 0,
            createdAt: DateTime.parse(r['created_at'] as String),
          ),
        )
        .toList();
  }

  // =========================================================================
  // COMMENTS & ADS PERSISTENCE
  // =========================================================================

  void insertComment(ArticleComment comment) {
    db.execute(
      '''
      INSERT OR REPLACE INTO article_comments (id, article_id, author, avatar_url, text, time_ago, created_at, likes)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        comment.id,
        comment.articleId,
        comment.author,
        comment.avatarUrl,
        comment.text,
        comment.timeAgo,
        comment.createdAt.toIso8601String(),
        comment.likes,
      ],
    );
  }

  List<ArticleComment> getComments(String articleId) {
    final rows = db.select(
      'SELECT * FROM article_comments WHERE article_id = ? ORDER BY created_at DESC',
      [articleId],
    );
    return rows
        .map(
          (r) => ArticleComment(
            id: r['id'] as String,
            articleId: r['article_id'] as String,
            author: r['author'] as String,
            avatarUrl: r['avatar_url'] as String,
            text: r['text'] as String,
            timeAgo: r['time_ago'] as String,
            createdAt: DateTime.parse(r['created_at'] as String),
            likes: r['likes'] as int? ?? 0,
          ),
        )
        .toList();
  }

  void updateCommentLikes(String commentId, int likes) {
    db.execute('UPDATE article_comments SET likes = ? WHERE id = ?', [likes, commentId]);
  }

  int getCommentCount() {
    final rows = db.select('SELECT COUNT(*) AS cnt FROM article_comments');
    return rows.first['cnt'] as int? ?? 0;
  }

  void upsertAd(SponsoredAd ad) {
    db.execute(
      '''
      INSERT OR REPLACE INTO sponsored_ads (id, payload_json, impressions, clicks)
      VALUES (?, ?, ?, ?)
      ''',
      [ad.id, jsonEncode(ad.toJson()), ad.impressions, ad.clicks],
    );
  }

  List<SponsoredAd> getAds() {
    final rows = db.select('SELECT payload_json, impressions, clicks FROM sponsored_ads');
    return rows.map((r) {
      final ad = SponsoredAd.fromJson(jsonDecode(r['payload_json'] as String) as Map<String, dynamic>);
      return ad.copyWith(
        impressions: r['impressions'] as int? ?? ad.impressions,
        clicks: r['clicks'] as int? ?? ad.clicks,
      );
    }).toList();
  }

  void dispose() => db.dispose();
}
