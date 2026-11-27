typedef KeyDownCallback = void Function(String key, bool isInputFocused);

void focusElementById(String elementId) {}

void setInputValueById(String elementId, String value) {}

Object? addWindowKeyDownListener(KeyDownCallback onKeyDown) => null;

void removeWindowKeyDownListener(Object? subscription) {}

Object? addWindowResizeListener(void Function() onResize) => null;

void removeWindowResizeListener(Object? subscription) {}

String? extractInputValue(dynamic event, {String? elementId}) => null;

String? extractKeyboardEventKey(dynamic event) => null;

void stopEventPropagation(dynamic event) {}
