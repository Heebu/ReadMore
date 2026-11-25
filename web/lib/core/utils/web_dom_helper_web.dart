import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

typedef KeyDownCallback = void Function(String key, bool isInputFocused);

void focusElementById(String elementId) {
  try {
    Future.microtask(() {
      final el = web.document.getElementById(elementId);
      if (el != null && el.isA<web.HTMLElement>()) {
        (el as web.HTMLElement).focus();
      }
    });
  } catch (_) {}
}

void setInputValueById(String elementId, String value) {
  try {
    final el = web.document.getElementById(elementId);
    if (el == null) return;
    if (el.isA<web.HTMLInputElement>()) {
      final input = el as web.HTMLInputElement;
      if (input.value != value) {
        input.value = value;
      }
    } else if (el.isA<web.HTMLTextAreaElement>()) {
      final textarea = el as web.HTMLTextAreaElement;
      if (textarea.value != value) {
        textarea.value = value;
      }
    }
  } catch (_) {}
}

Object? addWindowKeyDownListener(KeyDownCallback onKeyDown) {
  try {
    return web.EventStreamProviders.keyDownEvent.forTarget(web.window).listen((web.KeyboardEvent event) {
      final activeTag = web.document.activeElement?.tagName.toUpperCase() ?? '';
      final isInputFocused =
          activeTag == 'INPUT' || activeTag == 'TEXTAREA' || activeTag == 'SELECT';
      onKeyDown(event.key, isInputFocused);
    });
  } catch (_) {
    return null;
  }
}

void removeWindowKeyDownListener(Object? subscription) {
  try {
    if (subscription is StreamSubscription) {
      subscription.cancel();
    }
  } catch (_) {}
}

String? extractInputValue(dynamic event, {String? elementId}) {
  try {
    if (elementId != null) {
      final el = web.document.getElementById(elementId);
      if (el != null) {
        if (el.isA<web.HTMLInputElement>()) {
          return (el as web.HTMLInputElement).value;
        }
        if (el.isA<web.HTMLTextAreaElement>()) {
          return (el as web.HTMLTextAreaElement).value;
        }
      }
    }
    if (event != null) {
      final ev = event as web.Event;
      final target = ev.target;
      if (target != null) {
        if (target.isA<web.HTMLInputElement>()) {
          return (target as web.HTMLInputElement).value;
        }
        if (target.isA<web.HTMLTextAreaElement>()) {
          return (target as web.HTMLTextAreaElement).value;
        }
      }
    }
    return null;
  } catch (_) {
    return null;
  }
}

String? extractKeyboardEventKey(dynamic event) {
  try {
    if (event == null) return null;
    final kb = event as web.KeyboardEvent;
    return kb.key;
  } catch (_) {
    return null;
  }
}

void stopEventPropagation(dynamic event) {
  try {
    if (event != null) {
      (event as web.Event).stopPropagation();
    }
  } catch (_) {}
}
