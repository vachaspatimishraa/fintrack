import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/report_history_model.dart';
import '../domain/repositories/report_history_repository.dart';
import '../data/repositories/report_history_repository_impl.dart';

final reportHistoryRepositoryProvider = Provider<ReportHistoryRepository>((ref) {
  return ReportHistoryRepositoryImpl();
});

final reportHistoryStreamProvider = StreamProvider<List<ReportHistoryEntry>>((ref) {
  final repository = ref.watch(reportHistoryRepositoryProvider);
  return repository.watchReportHistory();
});

final reportHistorySearchQueryProvider = StateProvider<String>((ref) => '');
final reportHistoryFormatFilterProvider = StateProvider<String?>((ref) => null);
final reportHistoryTypeFilterProvider = StateProvider<String?>((ref) => null);

final reportHistoryListProvider = Provider<List<ReportHistoryEntry>>((ref) {
  final historyAsync = ref.watch(reportHistoryStreamProvider);
  final searchQuery = ref.watch(reportHistorySearchQueryProvider).toLowerCase();
  final formatFilter = ref.watch(reportHistoryFormatFilterProvider);
  final typeFilter = ref.watch(reportHistoryTypeFilterProvider);

  return historyAsync.maybeWhen(
    data: (list) {
      return list.where((e) {
        // Search
        if (searchQuery.isNotEmpty &&
            !e.reportName.toLowerCase().contains(searchQuery) &&
            !e.reportType.toLowerCase().contains(searchQuery)) {
          return false;
        }
        // Format filter
        if (formatFilter != null && e.exportFormat.toLowerCase() != formatFilter.toLowerCase()) {
          return false;
        }
        // Type filter
        if (typeFilter != null && e.reportType.toLowerCase() != typeFilter.toLowerCase()) {
          return false;
        }
        return true;
      }).toList();
    },
    orElse: () => [],
  );
});

final storageUsageProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final repository = ref.watch(reportHistoryRepositoryProvider);
  // Re-run whenever history changes
  ref.watch(reportHistoryStreamProvider);
  return repository.calculateStorageUsage();
});
