import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/transactions/providers/transaction_provider.dart';
import 'package:fintrack/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:fintrack/features/analytics/domain/entities/analytics_state.dart';
import 'package:fintrack/features/analytics/domain/repositories/analytics_repository.dart';

import 'package:fintrack/features/budget/providers/budget_provider.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  return AnalyticsRepositoryImpl(transactionRepo, budgetRepo);
});

final analyticsStreamProvider = StreamProvider<AnalyticsState>((ref) {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.watchAnalyticsState();
});
