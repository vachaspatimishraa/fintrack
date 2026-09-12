import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/analytics/domain/entities/financial_health_data.dart';
import 'package:fintrack/features/analytics/presentation/controllers/financial_health_controller.dart';
import 'package:fintrack/features/analytics/providers/analytics_provider.dart';

final financialHealthProvider = StreamProvider<FinancialHealthReport>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.watchFinancialHealthReport();
});

final financialHealthControllerProvider = Provider<FinancialHealthController>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return FinancialHealthController(repository, ref);
});
