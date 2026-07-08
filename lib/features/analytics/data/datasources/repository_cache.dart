class RepositoryCache {
  final Map<String, dynamic> _cacheMap = {};
  int _cacheHits = 0;
  int _cacheMisses = 0;

  RepositoryCache();

  int get cacheHits => _cacheHits;
  int get cacheMisses => _cacheMisses;

  T? get<T>(String key) {
    if (_cacheMap.containsKey(key)) {
      _cacheHits++;
      return _cacheMap[key] as T?;
    }
    _cacheMisses++;
    return null;
  }

  void put<T>(String key, T value) {
    _cacheMap[key] = value;
  }

  void clear() {
    _cacheMap.clear();
    _cacheHits = 0;
    _cacheMisses = 0;
  }

  bool contains(String key) {
    return _cacheMap.containsKey(key);
  }
}
