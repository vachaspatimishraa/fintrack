import 'package:fintrack/features/analytics/domain/entities/cash_flow_data.dart';

abstract class CashFlowRepository {
  Future<CashFlowReport> getCashFlowReport(String filter);
  Stream<CashFlowReport> watchCashFlowReport(String filter);
}
