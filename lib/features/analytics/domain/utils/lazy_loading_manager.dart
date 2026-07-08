import 'dart:math';

class LazyLoadingManager<T> {
  final List<T> _allItems;
  final int pageSize;
  int _currentPage = 1;

  LazyLoadingManager(this._allItems, {this.pageSize = 50});

  int get currentPage => _currentPage;
  int get totalPages => (_allItems.length / pageSize).ceil();
  bool get hasMore => _currentPage < totalPages;

  List<T> getNextPage() {
    if (_allItems.isEmpty) return [];
    final start = 0;
    final end = min((_currentPage * pageSize), _allItems.length);
    return _allItems.sublist(start, end);
  }

  void loadMore() {
    if (hasMore) {
      _currentPage++;
    }
  }

  void reset() {
    _currentPage = 1;
  }
}
