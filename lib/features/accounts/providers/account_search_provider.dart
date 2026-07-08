import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountSearchNotifier extends StateNotifier<String> {
  AccountSearchNotifier() : super('');

  void setSearchQuery(String query) {
    state = query.trim();
  }

  void clear() {
    state = '';
  }
}

final accountSearchProvider = StateNotifierProvider<AccountSearchNotifier, String>((ref) {
  return AccountSearchNotifier();
});
