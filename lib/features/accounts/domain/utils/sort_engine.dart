import '../../../../core/database/isar/collections/account_model.dart';
import '../../providers/account_sort_provider.dart';

class SortEngine {
  static void sort({
    required List<AccountModel> accounts,
    required AccountSortOption option,
  }) {
    accounts.sort((a, b) {
      switch (option) {
        case AccountSortOption.alphabetical:
          return a.name.compareTo(b.name);
        case AccountSortOption.newest:
          return b.createdAt.compareTo(a.createdAt);
        case AccountSortOption.oldest:
          return a.createdAt.compareTo(b.createdAt);
        case AccountSortOption.highestBalance:
          return b.balance.compareTo(a.balance);
        case AccountSortOption.lowestBalance:
          return a.balance.compareTo(b.balance);
        case AccountSortOption.mostRecentlyUsed:
          return b.updatedAt.compareTo(a.updatedAt);
        case AccountSortOption.leastRecentlyUsed:
          return a.updatedAt.compareTo(b.updatedAt);
      }
    });
  }
}
