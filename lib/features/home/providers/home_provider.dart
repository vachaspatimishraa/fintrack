import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../accounts/providers/account_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../sync/providers/sync_provider.dart';
import '../../transactions/domain/entities/transaction_entity.dart';
import '../domain/models/dashboard_model.dart';
import '../domain/models/home_state.dart';
import '../../../core/database/isar/collections/account_model.dart';

class HomeStateNotifier extends StateNotifier<HomeState> {
  final Ref _ref;
  ProviderSubscription? _transactionsSubscription;
  StreamSubscription? _accountsSubscription;
  StreamSubscription? _syncSubscription;

  HomeStateNotifier(this._ref) : super(const HomeState(isLoading: true)) {
    _init();
  }

  void _init() {
    // Listen to changes in the current account selection
    _ref.listen<AccountModel?>(currentAccountModelProvider, (previous, next) {
      _loadDashboardData();
    }, fireImmediately: true);

    // Listen to the transactions stream to automatically update dashboard on database changes
    _transactionsSubscription = _ref.listen<AsyncValue<List<TransactionEntity>>>(
      transactionsStreamProvider,
      (previous, next) {
        _loadDashboardData();
      },
    );

    // Listen to accounts stream to update dashboard if account balance changes
    final accountsStream = _ref.read(allAccountsStreamProvider.stream);
    _accountsSubscription = accountsStream.listen((_) {
      _loadDashboardData();
    });

    // Listen to sync progress status
    final syncStateStream = _ref.read(syncStatusProvider.notifier).stream;
    _syncSubscription = syncStateStream.listen((_) {
      _updateSyncStatus();
    });
  }

  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(selectedDateRange: range, clearDateRange: range == null);
    _loadDashboardData();
  }

  void setTypeFilter(String? type) {
    state = state.copyWith(selectedTypeFilter: type, clearTypeFilter: type == null);
    _loadDashboardData();
  }

  void setCategoryFilter(String? category) {
    state = state.copyWith(selectedCategoryFilter: category, clearCategoryFilter: category == null);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final currentAccount = _ref.read(currentAccountModelProvider);
    if (currentAccount == null) {
      state = state.copyWith(
        isLoading: false,
        dashboard: const DashboardModel(syncStatus: HomeSyncStatus.synced),
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final repository = _ref.read(transactionRepositoryProvider);
      final allTransactions = await repository.getTransactions();

      // Filter by current account uuid
      final accountTxList = allTransactions.where((tx) => tx.accountId == currentAccount.uuid).toList();

      // Sort newest first
      accountTxList.sort((a, b) => b.date.compareTo(a.date));

      // Calculate totals for the selected period
      final now = DateTime.now();
      final DateTimeRange activeRange = state.selectedDateRange ?? _getDefaultRangeForFilter(now);

      double incomeSum = 0.0;
      double expenseSum = 0.0;
      int filteredTxCount = 0;

      // Calculate total income/expense in the active range
      for (final tx in accountTxList) {
        final txDate = tx.date;
        if (!txDate.isBefore(activeRange.start) && !txDate.isAfter(activeRange.end)) {
          if (tx.type == 'income') {
            incomeSum += tx.amount;
          } else {
            expenseSum += tx.amount;
          }
          filteredTxCount++;
        }
      }

      // Calculate Opening Balance for the active range
      // Opening Balance = current balance - income (after range start) + expense (after range start)
      double subsequentIncome = 0.0;
      double subsequentExpense = 0.0;

      for (final tx in accountTxList) {
        if (tx.date.isAfter(activeRange.end)) {
          // Exclude transactions after the range completely
          if (tx.type == 'income') {
            subsequentIncome += tx.amount;
          } else {
            subsequentExpense += tx.amount;
          }
        }
      }

      // Also need to adjust for transactions within the active range itself because they are included in current account balance
      double rangeIncome = 0.0;
      double rangeExpense = 0.0;
      for (final tx in accountTxList) {
        if (!tx.date.isBefore(activeRange.start) && !tx.date.isAfter(activeRange.end)) {
          if (tx.type == 'income') {
            rangeIncome += tx.amount;
          } else {
            rangeExpense += tx.amount;
          }
        }
      }

      final openingBalance = currentAccount.balance - subsequentIncome - rangeIncome + subsequentExpense + rangeExpense;

      // Filter list shown in Dashboard (Recent transactions)
      // If a type filter is selected (Income/Expense card tapped), apply it
      var recentTx = accountTxList.where((tx) {
        // Date check
        if (tx.date.isBefore(activeRange.start) || tx.date.isAfter(activeRange.end)) {
          return false;
        }
        // Type filter check
        if (state.selectedTypeFilter != null && tx.type != state.selectedTypeFilter) {
          return false;
        }
        // Category filter check
        if (state.selectedCategoryFilter != null && tx.category != state.selectedCategoryFilter) {
          return false;
        }
        return true;
      }).toList();

      final syncStatus = _getCurrentHomeSyncStatus();

      state = state.copyWith(
        isLoading: false,
        clearError: true,
        dashboard: DashboardModel(
          currentAccount: currentAccount,
          income: incomeSum,
          expense: expenseSum,
          balance: openingBalance + incomeSum - expenseSum,
          transactionCount: filteredTxCount,
          recentTransactions: recentTx,
          syncStatus: syncStatus,
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _updateSyncStatus() {
    if (state.dashboard != null) {
      state = state.copyWith(
        dashboard: state.dashboard!.copyWith(
          syncStatus: _getCurrentHomeSyncStatus(),
        ),
      );
    }
  }

  HomeSyncStatus _getCurrentHomeSyncStatus() {
    final connectivity = _ref.read(connectivityServiceProvider);
    if (!connectivity.isConnected) {
      return HomeSyncStatus.offline;
    }
    final syncState = _ref.read(syncStatusProvider);
    if (syncState.isSyncing) {
      return HomeSyncStatus.syncing;
    }
    if (syncState.errorMessage != null) {
      return HomeSyncStatus.failed;
    }
    return HomeSyncStatus.synced;
  }

  DateTimeRange _getDefaultRangeForFilter(DateTime now) {
    // Default to Month range (from start of current month to end of current month)
    final start = DateTime(now.year, now.month, 1);
    final nextMonth = now.month == 12 ? 1 : now.month + 1;
    final nextMonthYear = now.month == 12 ? now.year + 1 : now.year;
    final end = DateTime(nextMonthYear, nextMonth, 1).subtract(const Duration(milliseconds: 1));
    return DateTimeRange(start: start, end: end);
  }

  DateTimeRange getRangeForPeriod(String period) {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (period.toLowerCase()) {
      case 'today':
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;
      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        start = DateTime(yesterday.year, yesterday.month, yesterday.day);
        end = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59, 999);
        break;
      case 'week':
        // Start of current week (assuming Monday as start)
        final daysToSubtract = now.weekday - 1;
        final monday = now.subtract(Duration(days: daysToSubtract));
        start = DateTime(monday.year, monday.month, monday.day);
        final sunday = monday.add(const Duration(days: 6));
        end = DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59, 999);
        break;
      case 'month':
        start = DateTime(now.year, now.month, 1);
        final nextMonth = now.month == 12 ? 1 : now.month + 1;
        final nextMonthYear = now.month == 12 ? now.year + 1 : now.year;
        end = DateTime(nextMonthYear, nextMonth, 1).subtract(const Duration(milliseconds: 1));
        break;
      case 'year':
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31, 23, 59, 59, 999);
        break;
      default:
        return _getDefaultRangeForFilter(now);
    }

    return DateTimeRange(start: start, end: end);
  }

  Future<void> refreshDashboard() async {
    // Invalidate streams and trigger sync
    _ref.invalidate(transactionsStreamProvider);
    _ref.invalidate(accountsStreamProvider);
    _ref.invalidate(allAccountsStreamProvider);
    await _ref.read(syncStatusProvider.notifier).triggerSync();
    await _loadDashboardData();
  }

  @override
  void dispose() {
    _transactionsSubscription?.close();
    _accountsSubscription?.cancel();
    _syncSubscription?.cancel();
    super.dispose();
  }
}

final homeStateProvider = StateNotifierProvider<HomeStateNotifier, HomeState>((ref) {
    return HomeStateNotifier(ref);
  },
);
