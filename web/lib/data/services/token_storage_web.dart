// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

String? readStoredValue(String key) {
  try {
    return html.window.localStorage[key];
  } catch (_) {
    return null;
  }
}

void writeStoredValue(String key, String value) {
  try {
    html.window.localStorage[key] = value;
  } catch (_) {}
}

void removeStoredValue(String key) {
  try {
    html.window.localStorage.remove(key);
  } catch (_) {}
}
