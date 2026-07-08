import '../entities/expense_data.dart';

abstract class ExpenseRepository {
  Future<ExpenseReport> getExpenseReport(String filter);
  Stream<ExpenseReport> watchExpenseReport(String filter);
}
