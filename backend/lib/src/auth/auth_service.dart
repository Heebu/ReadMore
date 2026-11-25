import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:news_models/news_models.dart';
import '../storage/database_service.dart';

/// Cryptographically secure authentication, SQLite user persistence,
/// Google ID token verification, password reset, and JWT service.
class AuthService {
  final String jwtSecret;
  final String? googleClientId;
  final Duration tokenDuration;
  final DatabaseService _db;
  final http.Client _httpClient;

  AuthService({
    String? jwtSecret,
    String? googleClientId,
    this.tokenDuration = const Duration(days: 7),
    DatabaseService? db,
    http.Client? httpClient,
  })  : jwtSecret = jwtSecret ??
            Platform.environment['READMORE_JWT_SECRET'] ??
            'readmore_dev_jwt_secret_change_in_production_2026!',
        googleClientId = googleClientId ?? Platform.environment['GOOGLE_CLIENT_ID'],
        _db = db ?? DatabaseService.inMemory(),
        _httpClient = httpClient ?? http.Client() {
    _seedDefaultUser();
  }

  void _seedDefaultUser() {
    if (_db.getUserRecordByEmail('demo@readmore.com') == null) {
      register(
        email: 'demo@readmore.com',
        password: 'Password123!',
        displayName: 'News Reader',
      );
    }
  }

  /// Register a new user with hashed password, persisted in SQLite.
  User register({
    required String email,
    required String password,
    required String displayName,
    String? avatarUrl,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    if (!normalizedEmail.contains('@') || !normalizedEmail.contains('.')) {
      throw Exception('Please provide a valid email address.');
    }
    if (_db.getUserRecordByEmail(normalizedEmail) != null) {
      throw Exception('A user with email $normalizedEmail already exists.');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters long.');
    }

    final userId = 'usr_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
    final salt = _generateRandomSalt();
    final hash = _hashPassword(password, salt);

    final user = User(
      id: userId,
      email: normalizedEmail,
      displayName: displayName.trim().isNotEmpty ? displayName.trim() : normalizedEmail.split('@').first,
      avatarUrl: avatarUrl,
      role: 'user',
      createdAt: DateTime.now(),
      preferences: const UserPreferences(),
      readingStreakDays: 1,
      articlesReadCount: 0,
    );

    final today = _todayUtcString();
    _db.upsertUser(user, passwordHash: '$hash\$$salt', lastActiveDate: today);
    return user;
  }

  /// Authenticate user and return (User, JWT Token).
  ({User user, String token}) login({
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final record = _db.getUserRecordByEmail(normalizedEmail);
    if (record == null || record.passwordHash == null) {
      throw Exception('Invalid email or password.');
    }

    final parts = record.passwordHash!.split('\$');
    if (parts.length != 2) {
      throw Exception('Invalid email or password.');
    }
    final expectedHash = parts[0];
    final salt = parts[1];

    final calculatedHash = _hashPassword(password, salt);
    if (calculatedHash != expectedHash) {
      throw Exception('Invalid email or password.');
    }

    final updatedUser = _touchDailyStreak(record.user, record.lastActiveDate);
    final token = generateToken(updatedUser);

    return (user: updatedUser, token: token);
  }

  /// Verifies a Google Identity Services ID token against Google's tokeninfo
  /// endpoint when provided. If [googleClientId] is configured on the server,
  /// rejects requests without a valid verified ID token.
  Future<({User user, String token, bool verifiedByGoogle})> verifyAndLoginWithGoogle({
    String? idToken,
    String? email,
    String? displayName,
    String? avatarUrl,
  }) async {
    var resolvedEmail = email;
    var resolvedName = displayName;
    var resolvedAvatar = avatarUrl;
    var verified = false;

    if (idToken != null && idToken.trim().isNotEmpty) {
      final uri = Uri.https('oauth2.googleapis.com', '/tokeninfo', {'id_token': idToken.trim()});
      final resp = await _httpClient.get(uri).timeout(const Duration(seconds: 5));
      if (resp.statusCode != 200) {
        throw Exception('Google ID token verification failed.');
      }
      final claims = jsonDecode(resp.body) as Map<String, dynamic>;
      if (claims['email_verified'] != 'true' && claims['email_verified'] != true) {
        throw Exception('Google account email is not verified.');
      }
      if (googleClientId != null && googleClientId!.isNotEmpty && claims['aud'] != googleClientId) {
        throw Exception('Google token audience mismatch.');
      }
      resolvedEmail = claims['email'] as String?;
      resolvedName = claims['name'] as String? ?? claims['given_name'] as String?;
      resolvedAvatar = claims['picture'] as String?;
      verified = true;
    } else if (googleClientId != null && googleClientId!.isNotEmpty) {
      throw Exception('Google ID token is required in production mode.');
    }

    final result = loginOrRegisterOAuth(
      email: (resolvedEmail?.trim().isNotEmpty == true) ? resolvedEmail!.trim() : 'alex.rivera@readmore.org',
      displayName: (resolvedName?.trim().isNotEmpty == true) ? resolvedName!.trim() : 'Alex Rivera',
      avatarUrl: resolvedAvatar,
    );
    return (user: result.user, token: result.token, verifiedByGoogle: verified);
  }

  /// Authenticate or register an OAuth reader and persist in SQLite.
  ({User user, String token}) loginOrRegisterOAuth({
    required String email,
    required String displayName,
    String? avatarUrl,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final existing = _db.getUserRecordByEmail(normalizedEmail);
    User user;
    if (existing == null) {
      final userId = 'usr_oauth_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
      user = User(
        id: userId,
        email: normalizedEmail,
        displayName: displayName.trim().isNotEmpty ? displayName.trim() : 'Google Reader',
        avatarUrl: avatarUrl,
        role: 'user',
        createdAt: DateTime.now(),
        preferences: const UserPreferences(),
        readingStreakDays: 1,
        articlesReadCount: 0,
      );
      _db.upsertUser(user, lastActiveDate: _todayUtcString());
    } else {
      user = _touchDailyStreak(existing.user, existing.lastActiveDate);
      if (avatarUrl != null && user.avatarUrl != avatarUrl) {
        user = updateUser(user.copyWith(avatarUrl: avatarUrl));
      }
    }

    final token = generateToken(user);
    return (user: user, token: token);
  }

  /// Issues a short-lived password reset code (15 minutes) for an email.
  String requestPasswordReset(String email) {
    final record = _db.getUserRecordByEmail(email.trim().toLowerCase());
    if (record == null) {
      throw Exception('No account found with that email address.');
    }
    final code = (100000 + Random.secure().nextInt(899999)).toString();
    _db.saveResetToken(
      code,
      record.user.id,
      DateTime.now().toUtc().add(const Duration(minutes: 15)),
    );
    return code;
  }

  /// Consumes a password reset code and sets a new salted password hash.
  void resetPassword({required String token, required String newPassword}) {
    if (newPassword.length < 6) {
      throw Exception('New password must be at least 6 characters long.');
    }
    final resetRecord = _db.consumeResetToken(token.trim());
    if (resetRecord == null) {
      throw Exception('Invalid or expired password reset code.');
    }
    if (DateTime.now().toUtc().isAfter(resetRecord.expiresAt)) {
      throw Exception('Password reset code has expired.');
    }
    final salt = _generateRandomSalt();
    final hash = _hashPassword(newPassword, salt);
    _db.updatePasswordHash(resetRecord.userId, '$hash\$$salt');
  }

  /// Allows an authenticated user to change their password after verifying current password.
  void changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) {
    if (newPassword.length < 6) {
      throw Exception('New password must be at least 6 characters long.');
    }
    final record = _db.getUserRecordById(userId);
    if (record == null) {
      throw Exception('User not found.');
    }
    if (record.passwordHash != null) {
      final parts = record.passwordHash!.split('\$');
      if (parts.length == 2 && _hashPassword(currentPassword, parts[1]) != parts[0]) {
        throw Exception('Current password is incorrect.');
      }
    }
    final salt = _generateRandomSalt();
    final hash = _hashPassword(newPassword, salt);
    _db.updatePasswordHash(userId, '$hash\$$salt');
  }

  User? getUserById(String userId) => _db.getUserRecordById(userId)?.user;

  User? getUserByEmail(String email) => _db.getUserRecordByEmail(email)?.user;

  User updateUser(User updatedUser) {
    if (_db.getUserRecordById(updatedUser.id) == null) {
      throw Exception('User not found.');
    }
    _db.upsertUser(updatedUser);
    return updatedUser;
  }

  /// Increments articles read count and maintains daily reading streak in SQLite.
  User? recordArticleRead(String userId) {
    final record = _db.getUserRecordById(userId);
    if (record == null) return null;
    final touched = _touchDailyStreak(record.user, record.lastActiveDate);
    final incremented = touched.copyWith(articlesReadCount: touched.articlesReadCount + 1);
    _db.upsertUser(incremented, lastActiveDate: _todayUtcString());
    return incremented;
  }

  User _touchDailyStreak(User user, String? lastActiveDate) {
    final today = _todayUtcString();
    if (lastActiveDate == today) return user;

    var nextStreak = user.readingStreakDays;
    if (lastActiveDate != null) {
      final prev = DateTime.tryParse(lastActiveDate);
      final cur = DateTime.tryParse(today);
      if (prev != null && cur != null) {
        final diffDays = cur.difference(prev).inDays;
        if (diffDays == 1) {
          nextStreak += 1;
        } else if (diffDays > 1) {
          nextStreak = 1;
        }
      }
    }
    final updated = user.copyWith(readingStreakDays: nextStreak);
    _db.upsertUser(updated, lastActiveDate: today);
    return updated;
  }

  String _todayUtcString() => DateTime.now().toUtc().toIso8601String().substring(0, 10);

  /// Upgrade user's subscription tier to 'pro' and enable ad-free mode.
  User upgradeSubscription(String userId, {String plan = 'annual', String paymentMethod = 'stripe'}) {
    final user = getUserById(userId);
    if (user == null) {
      throw Exception('User not found.');
    }
    final updated = user.copyWith(
      subscriptionTier: 'pro',
      adFreeEnabled: true,
    );
    return updateUser(updated);
  }

  /// Cancel user's Pro subscription and revert to free tier.
  User cancelSubscription(String userId) {
    final user = getUserById(userId);
    if (user == null) {
      throw Exception('User not found.');
    }
    final updated = user.copyWith(
      subscriptionTier: 'free',
      adFreeEnabled: false,
    );
    return updateUser(updated);
  }

  /// Toggle ad-free viewing preference for Pro subscribers.
  User toggleAdFree(String userId) {
    final user = getUserById(userId);
    if (user == null) {
      throw Exception('User not found.');
    }
    final updated = user.copyWith(
      adFreeEnabled: !user.adFreeEnabled,
    );
    return updateUser(updated);
  }

  /// Generate an RFC 7519 compliant HMAC-SHA256 JWT.
  String generateToken(User user) {
    final header = {
      'alg': 'HS256',
      'typ': 'JWT',
    };

    final now = DateTime.now().toUtc();
    final expiry = now.add(tokenDuration);

    final payload = {
      'sub': user.id,
      'email': user.email,
      'name': user.displayName,
      'role': user.role,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': expiry.millisecondsSinceEpoch ~/ 1000,
    };

    final headerB64 = _base64UrlEncode(jsonEncode(header));
    final payloadB64 = _base64UrlEncode(jsonEncode(payload));
    final unsignedToken = '$headerB64.$payloadB64';

    final signature = _signHmac(unsignedToken, jwtSecret);
    return '$unsignedToken.$signature';
  }

  /// Verify and decode JWT token into claims map, returning null if invalid or expired.
  Map<String, dynamic>? verifyToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final headerB64 = parts[0];
      final payloadB64 = parts[1];
      final signatureB64 = parts[2];

      final unsignedToken = '$headerB64.$payloadB64';
      final expectedSignature = _signHmac(unsignedToken, jwtSecret);

      if (signatureB64 != expectedSignature) {
        return null;
      }

      final payloadJson = utf8.decode(base64Url.decode(base64Url.normalize(payloadB64)));
      final claims = jsonDecode(payloadJson) as Map<String, dynamic>;

      final exp = claims['exp'] as int?;
      if (exp != null) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
        if (DateTime.now().toUtc().isAfter(expiry)) {
          return null;
        }
      }

      return claims;
    } catch (_) {
      return null;
    }
  }

  String _signHmac(String data, String key) {
    final hmac = Hmac(sha256, utf8.encode(key));
    final digest = hmac.convert(utf8.encode(data));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  String _base64UrlEncode(String input) {
    return base64Url.encode(utf8.encode(input)).replaceAll('=', '');
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt:$password:$salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _generateRandomSalt([int length = 16]) {
    final rand = Random.secure();
    final values = List<int>.generate(length, (i) => rand.nextInt(256));
    return base64Url.encode(values).replaceAll('=', '');
  }
}
