import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteTransactionNotifier extends StateNotifier<Set<String>> {
  FavoriteTransactionNotifier() : super({});

  void toggleFavorite(String uuid) {
    if (state.contains(uuid)) {
      state = {...state}..remove(uuid);
    } else {
      state = {...state, uuid};
    }
  }

  bool isFavorite(String uuid) {
    return state.contains(uuid);
  }
}

final favoriteTransactionProvider = StateNotifierProvider<FavoriteTransactionNotifier, Set<String>>((ref) {
  return FavoriteTransactionNotifier();
});
