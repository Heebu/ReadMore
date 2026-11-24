import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:news_models/news_models.dart';

/// Cryptographically secure authentication and JWT service
class AuthService {
  final String jwtSecret;
  final Duration tokenDuration;

  // In-memory user database (pluggable with PostgreSQL)
  final Map<String, User> _usersById = {};
  final Map<String, String> _passwordHashes = {}; // userId -> hash$salt
  final Map<String, String> _emailToUserId = {};

  AuthService({
    String? jwtSecret,
    this.tokenDuration = const Duration(days: 7),
  }) : jwtSecret = jwtSecret ?? 'readmore_super_secret_jwt_key_2026_production!' {
    // Seed initial demo user for instant testing
    _seedDefaultUser();
  }

  void _seedDefaultUser() {
    register(
      email: 'demo@readmore.com',
      password: 'Password123!',
      displayName: 'News Reader',
    );
  }

  /// Register a new user with hashed password and default preferences
  User register({
    required String email,
    required String password,
    required String displayName,
    String? avatarUrl,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    if (_emailToUserId.containsKey(normalizedEmail)) {
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
      displayName: displayName.trim(),
      avatarUrl: avatarUrl,
      role: 'user',
      createdAt: DateTime.now(),
      preferences: const UserPreferences(),
    );

    _usersById[userId] = user;
    _passwordHashes[userId] = '$hash\$$salt';
    _emailToUserId[normalizedEmail] = userId;

    return user;
  }

  /// Authenticate user and return (User, JWT Token)
  ({User user, String token}) login({
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final userId = _emailToUserId[normalizedEmail];
    if (userId == null) {
      throw Exception('Invalid email or password.');
    }

    final hashData = _passwordHashes[userId];
    if (hashData == null) {
      throw Exception('Invalid email or password.');
    }

    final parts = hashData.split('\$');
    if (parts.length != 2) {
      throw Exception('Corrupted password record.');
    }
    final expectedHash = parts[0];
    final salt = parts[1];

    final calculatedHash = _hashPassword(password, salt);
    if (calculatedHash != expectedHash) {
      throw Exception('Invalid email or password.');
    }

    final user = _usersById[userId]!;
    final token = generateToken(user);

    return (user: user, token: token);
  }

  User? getUserById(String userId) => _usersById[userId];

  User? getUserByEmail(String email) {
    final id = _emailToUserId[email.trim().toLowerCase()];
    if (id == null) return null;
    return _usersById[id];
  }

  User updateUser(User updatedUser) {
    if (!_usersById.containsKey(updatedUser.id)) {
      throw Exception('User not found.');
    }
    _usersById[updatedUser.id] = updatedUser;
    return updatedUser;
  }

  /// Upgrade user's subscription tier to 'pro' and enable ad-free mode
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

  /// Toggle ad-free viewing preference for Pro subscribers
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

  /// Generate an RFC 7519 compliant HMAC-SHA256 JWT
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

  /// Verify and decode JWT token into claims map, returning null if invalid or expired
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
        return null; // Invalid signature
      }

      final payloadJson = utf8.decode(base64Url.decode(base64Url.normalize(payloadB64)));
      final claims = jsonDecode(payloadJson) as Map<String, dynamic>;

      final exp = claims['exp'] as int?;
      if (exp != null) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
        if (DateTime.now().toUtc().isAfter(expiry)) {
          return null; // Expired
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
