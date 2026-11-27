import 'package:flutter/foundation.dart';

/// Application runtime configuration for ReadMore mobile & tablet builds.
class AppConfig {
  AppConfig._();

  static const String _envApiUrl =
      String.fromEnvironment('READMORE_API_URL', defaultValue: '');

  /// Resolves the Dart Frog backend URL across platforms.
  ///
  /// Uses `--dart-define=READMORE_API_URL=...` if provided; otherwise points
  /// Android emulators to host loopback `10.0.2.2:8085` and iOS/desktop to
  /// `localhost:8085`.
  static String get apiBaseUrl {
    if (_envApiUrl.isNotEmpty) return _envApiUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8085/api';
    }
    return 'http://localhost:8085/api';
  }

  /// Canonical web origin for deep linking (`readmore://` and `https://readmore.news`).
  static const String deepLinkScheme = 'readmore';
  static const String webDomain = 'readmore.news';

  /// Google AdMob official sample test IDs (override via `--dart-define`).
  static const String _androidBannerOverride =
      String.fromEnvironment('ADMOB_ANDROID_BANNER_ID', defaultValue: '');
  static const String _iosBannerOverride =
      String.fromEnvironment('ADMOB_IOS_BANNER_ID', defaultValue: '');

  static bool get supportsAdMob =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _iosBannerOverride.isNotEmpty
          ? _iosBannerOverride
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    return _androidBannerOverride.isNotEmpty
        ? _androidBannerOverride
        : 'ca-app-pub-3940256099942544/6300978111';
  }
}
