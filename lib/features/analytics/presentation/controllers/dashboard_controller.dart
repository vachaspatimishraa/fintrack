import '../../domain/repositories/analytics_repository.dart';

class DashboardController {
  final AnalyticsRepository _repository;

  DashboardController(this._repository);

  Future<void> handleRefresh() async {
    await _repository.getAnalyticsState();
  }
}
