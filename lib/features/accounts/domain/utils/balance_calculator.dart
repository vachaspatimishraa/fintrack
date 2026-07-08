class BalanceCalculator {
  static double calculateCurrentBalance({
    required double openingBalance,
    required double income,
    required double expense,
  }) {
    return openingBalance + income - expense;
  }
}
