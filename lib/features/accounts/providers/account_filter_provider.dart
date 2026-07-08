import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AccountFilterOption {
  all,
  active,
  archived,
  deleted,
  synced,
  pendingSync,
}

class AccountFilterNotifier extends StateNotifier<AccountFilterOption> {
  AccountFilterNotifier() : super(AccountFilterOption.active);

  void setFilterOption(AccountFilterOption option) {
    state = option;
  }
}

final accountFilterProvider = StateNotifierProvider<AccountFilterNotifier, AccountFilterOption>((ref) {
  return AccountFilterNotifier();
});
