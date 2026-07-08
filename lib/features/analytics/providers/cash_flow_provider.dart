import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/repositories/cash_flow_repository_impl.dart';
import '../domain/entities/cash_flow_data.dart';
import '../domain/repositories/cash_flow_repository.dart';

final cashFlowTimeFilterProvider = StateProvider<String>((ref) => '30days');

final cashFlowRepositoryProvider = Provider<CashFlowRepository>((ref) {
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  return CashFlowRepositoryImpl(transactionRepo);
});

final cashFlowReportProvider = StreamProvider<CashFlowReport>((ref) {
  final repo = ref.watch(cashFlowRepositoryProvider);
  final filter = ref.watch(cashFlowTimeFilterProvider);
  return repo.watchCashFlowReport(filter);
});
