import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

String? getConfiguredGoogleClientId() {
  try {
    final meta = html.document.querySelector('meta[name="google-signin-client_id"]');
    final content = meta?.getAttribute('content')?.trim();
    if (content != null && content.isNotEmpty) return content;
  } catch (_) {}
  return null;
}

/// Triggers Google Identity Services (One-Tap / credential prompt) if
/// `meta[name="google-signin-client_id"]` is configured in `index.html`.
/// Returns a Google-signed ID token string, or `null` if unconfigured.
Future<String?> requestGoogleIdToken() async {
  final clientId = getConfiguredGoogleClientId();
  if (clientId == null) return null;

  try {
    final google = js.context['google'];
    if (google == null) return null;
    final accounts = google['accounts'];
    if (accounts == null) return null;
    final idApi = accounts['id'];
    if (idApi == null) return null;

    final completer = Completer<String?>();
    idApi.callMethod('initialize', [
      js.JsObject.jsify({
        'client_id': clientId,
        'callback': js.allowInterop((dynamic response) {
          if (!completer.isCompleted) {
            final cred = response != null ? response['credential'] as String? : null;
            completer.complete(cred);
          }
        }),
      }),
    ]);
    idApi.callMethod('prompt');

    return await completer.future.timeout(
      const Duration(seconds: 25),
      onTimeout: () => null,
    );
  } catch (_) {
    return null;
  }
}
