import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/report_history_repository.dart';
import '../../providers/report_history_provider.dart';

class ReportHistoryController {
  final ReportHistoryRepository _repository;
  final Ref ref;

  ReportHistoryController(this._repository, this.ref);

  Future<void> renameReport(String id, String newName) async {
    await _repository.renameReport(id, newName);
    ref.invalidate(reportHistoryStreamProvider);
  }

  Future<void> deleteReport(String id) async {
    await _repository.deleteReport(id);
    ref.invalidate(reportHistoryStreamProvider);
  }

  Future<void> clearAll() async {
    await _repository.deleteAllReports();
    ref.invalidate(reportHistoryStreamProvider);
  }

  void updateSearchQuery(String query) {
    ref.read(reportHistorySearchQueryProvider.notifier).state = query;
  }

  void updateFormatFilter(String? format) {
    ref.read(reportHistoryFormatFilterProvider.notifier).state = format;
  }

  void updateTypeFilter(String? type) {
    ref.read(reportHistoryTypeFilterProvider.notifier).state = type;
  }
}

final reportHistoryControllerProvider = Provider<ReportHistoryController>((ref) {
  final repository = ref.watch(reportHistoryRepositoryProvider);
  return ReportHistoryController(repository, ref);
});
