import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/weekly_report_data.dart';
import '../../domain/repositories/weekly_report_repository.dart';

class WeeklyReportController {
  final WeeklyReportRepository _repository;
  final Ref ref;

  WeeklyReportController(this._repository, this.ref);

  DateTime previousWeek(DateTime weekAnchor) {
    return weekAnchor.subtract(const Duration(days: 7));
  }

  DateTime nextWeek(DateTime weekAnchor) {
    return weekAnchor.add(const Duration(days: 7));
  }

  DateTime currentWeek() => DateTime.now();

  String weekLabel(WeeklyReport report) {
    return '${report.weekStart.day} ${_month(report.weekStart.month)} - '
        '${report.weekEnd.day} ${_month(report.weekEnd.month)}';
  }

  List<String> recommendations(WeeklyReport report) {
    return report.recommendations;
  }

  bool isOfflineMode() => false;

  WeeklyReportRepository get repository => _repository;

  String _month(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }
}
