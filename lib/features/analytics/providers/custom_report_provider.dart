import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/custom_report_data.dart';
import '../presentation/controllers/custom_report_controller.dart';
import 'analytics_provider.dart';

final customReportFilterProvider = StateProvider<CustomReportFilter>((ref) {
  return CustomReportFilter.empty();
});

final customReportGroupByProvider = StateProvider<String>((ref) {
  return 'category';
});

final customReportSortByProvider = StateProvider<String>((ref) {
  return 'newest';
});

final customReportDatasetProvider = FutureProvider<CustomReportDataset>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  final filter = ref.watch(customReportFilterProvider);
  final groupBy = ref.watch(customReportGroupByProvider);
  final sortBy = ref.watch(customReportSortByProvider);

  // Listen to transaction updates/refreshes automatically if we want
  // Wait, transactions are updated reactively. If we want it to react to transaction changes,
  // we can watch analyticsStreamProvider or watch transactions stream.
  // Let's watch analyticsStreamProvider so it rebuilds when transactions change!
  ref.watch(analyticsStreamProvider);

  return repository.generateCustomReport(filter, groupBy, sortBy);
});

final savedReportsProvider = StreamProvider<List<CustomReportConfig>>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.watchCustomReports();
});

final customReportControllerProvider = Provider<CustomReportController>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return CustomReportController(repository, ref);
});
