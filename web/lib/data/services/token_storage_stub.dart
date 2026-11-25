final Map<String, String> _memoryStorage = {};

String? readStoredValue(String key) => _memoryStorage[key];

void writeStoredValue(String key, String value) {
  _memoryStorage[key] = value;
}

void removeStoredValue(String key) {
  _memoryStorage.remove(key);
}
