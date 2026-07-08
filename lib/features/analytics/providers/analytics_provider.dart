import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/repositories/analytics_repository_impl.dart';
import '../domain/entities/analytics_state.dart';
import '../domain/repositories/analytics_repository.dart';

import '../../budget/providers/budget_provider.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  return AnalyticsRepositoryImpl(transactionRepo, budgetRepo);
});

final analyticsStreamProvider = StreamProvider<AnalyticsState>((ref) {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.watchAnalyticsState();
});
