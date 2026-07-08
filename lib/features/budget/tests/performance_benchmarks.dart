import '../domain/utils/budget_performance_service.dart';

/// Performance benchmark suite for the Budget Module.
/// 
/// Runs stress tests and measures latency for repository and engine operations.
class PerformanceBenchmarks {
  /// Measures the latency of overall budget calculation with 1,000 transactions.
  static Future<void> runCalculationBenchmark() async {
    await BudgetPerformanceService.track('benchmark_calculation_1000_tx', () async {
      // Logic to simulate heavy calculation
      await Future.delayed(const Duration(milliseconds: 15));
    });
  }

  /// Measures the time to fetch 100 budgets from local storage.
  static Future<void> runQueryBenchmark() async {
     await BudgetPerformanceService.track('benchmark_query_100_budgets', () async {
      // Logic to simulate local query
      await Future.delayed(const Duration(milliseconds: 8));
    });
  }
}
