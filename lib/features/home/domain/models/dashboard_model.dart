import '../../../../core/database/isar/collections/account_model.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

enum HomeSyncStatus {
  synced,
  syncing,
  offline,
  failed,
}

class DashboardModel {
  final AccountModel? currentAccount;
  final double income;
  final double expense;
  final double balance;
  final int transactionCount;
  final List<TransactionEntity> recentTransactions;
  final HomeSyncStatus syncStatus;

  const DashboardModel({
    this.currentAccount,
    this.income = 0.0,
    this.expense = 0.0,
    this.balance = 0.0,
    this.transactionCount = 0,
    this.recentTransactions = const [],
    this.syncStatus = HomeSyncStatus.synced,
  });

  DashboardModel copyWith({
    AccountModel? currentAccount,
    double? income,
    double? expense,
    double? balance,
    int? transactionCount,
    List<TransactionEntity>? recentTransactions,
    HomeSyncStatus? syncStatus,
    bool clearAccount = false,
  }) {
    return DashboardModel(
      currentAccount: clearAccount ? null : (currentAccount ?? this.currentAccount),
      income: income ?? this.income,
      expense: expense ?? this.expense,
      balance: balance ?? this.balance,
      transactionCount: transactionCount ?? this.transactionCount,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
