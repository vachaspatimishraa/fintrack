import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AccountSortOption {
  alphabetical,
  newest,
  oldest,
  highestBalance,
  lowestBalance,
  mostRecentlyUsed,
  leastRecentlyUsed,
}

class AccountSortNotifier extends StateNotifier<AccountSortOption> {
  AccountSortNotifier() : super(AccountSortOption.alphabetical);

  void setSortOption(AccountSortOption option) {
    state = option;
  }
}

final accountSortProvider = StateNotifierProvider<AccountSortNotifier, AccountSortOption>((ref) {
  return AccountSortNotifier();
});
