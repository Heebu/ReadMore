import 'package:shared_preferences/shared_preferences.dart';

/// Local persistent key-value store backed by [SharedPreferences].
class TokenStorageService {
  static const String _tokenKey = 'readmore_jwt_token';
  static const String _signedOutKey = 'readmore_signed_out';
  static const String _darkModeKey = 'readmore_dark_mode';
  static const String _cityKey = 'readmore_selected_city';
  static const String _editionKey = 'readmore_selected_edition';
  static const String _bookmarksKey = 'readmore_guest_bookmarks';
  static const String _readLaterKey = 'readmore_guest_read_later';
  static const String _interestsKey = 'readmore_guest_interests';

  final SharedPreferences? _prefs;

  TokenStorageService([this._prefs]);

  static Future<TokenStorageService> create() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return TokenStorageService(prefs);
    } catch (_) {
      return TokenStorageService();
    }
  }

  String? getToken() => _prefs?.getString(_tokenKey);

  Future<void> saveToken(String? token) async {
    final p = _prefs;
    if (p == null) return;
    if (token != null && token.isNotEmpty) {
      await p.setString(_tokenKey, token);
      await p.setBool(_signedOutKey, false);
    } else {
      await p.remove(_tokenKey);
    }
  }

  bool get wasExplicitlySignedOut => _prefs?.getBool(_signedOutKey) ?? false;

  Future<void> markSignedOut() async {
    final p = _prefs;
    if (p == null) return;
    await p.remove(_tokenKey);
    await p.setBool(_signedOutKey, true);
  }

  bool? getDarkMode() => _prefs?.getBool(_darkModeKey);

  Future<void> saveDarkMode(bool isDark) async {
    await _prefs?.setBool(_darkModeKey, isDark);
  }

  String? getCity() => _prefs?.getString(_cityKey);
  String? getEdition() => _prefs?.getString(_editionKey);

  Future<void> saveLocation(String city, String edition) async {
    await _prefs?.setString(_cityKey, city);
    await _prefs?.setString(_editionKey, edition);
  }

  List<String> getGuestBookmarks() =>
      _prefs?.getStringList(_bookmarksKey) ?? const [];

  Future<void> saveGuestBookmarks(List<String> ids) async {
    await _prefs?.setStringList(_bookmarksKey, ids);
  }

  List<String> getGuestReadLater() =>
      _prefs?.getStringList(_readLaterKey) ?? const [];

  Future<void> saveGuestReadLater(List<String> ids) async {
    await _prefs?.setStringList(_readLaterKey, ids);
  }

  List<String> getGuestInterests() =>
      _prefs?.getStringList(_interestsKey) ?? const [];

  Future<void> saveGuestInterests(List<String> topics) async {
    await _prefs?.setStringList(_interestsKey, topics);
  }
}
