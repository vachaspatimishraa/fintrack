import '../entities/income_data.dart';

abstract class IncomeRepository {
  Future<IncomeReport> getIncomeReport(String filter);
  Stream<IncomeReport> watchIncomeReport(String filter);
}
