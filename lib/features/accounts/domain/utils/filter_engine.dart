import '../../../../core/database/isar/collections/account_model.dart';
import '../../providers/account_filter_provider.dart';

class FilterEngine {
  static List<AccountModel> filter({
    required List<AccountModel> accounts,
    required AccountFilterOption option,
  }) {
    return accounts.where((item) {
      switch (option) {
        case AccountFilterOption.all:
          return !item.isDeleted;
        case AccountFilterOption.active:
          return !item.isDeleted && !item.isArchived;
        case AccountFilterOption.archived:
          return !item.isDeleted && item.isArchived;
        case AccountFilterOption.deleted:
          return item.isDeleted;
        case AccountFilterOption.synced:
          return !item.isDeleted && item.isSynced;
        case AccountFilterOption.pendingSync:
          return !item.isDeleted && !item.isSynced;
      }
    }).toList();
  }
}
