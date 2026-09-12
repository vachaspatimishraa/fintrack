import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:fintrack/features/analytics/providers/financial_health_provider.dart';

class FinancialHealthController {
  final AnalyticsRepository repository;
  final Ref ref;

  FinancialHealthController(this.repository, this.ref);

  void refresh() {
    ref.invalidate(financialHealthProvider);
  }
}
