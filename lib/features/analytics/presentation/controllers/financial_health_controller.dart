import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../providers/financial_health_provider.dart';

class FinancialHealthController {
  final AnalyticsRepository _repository;
  final Ref ref;

  FinancialHealthController(this._repository, this.ref);

  void refresh() {
    ref.invalidate(financialHealthProvider);
  }
}
