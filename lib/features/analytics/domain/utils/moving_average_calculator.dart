class MovingAverageCalculator {
  const MovingAverageCalculator._();

  static List<double> calculate(List<double> values, {int window = 7}) {
    if (values.isEmpty) return [];
    final normalizedWindow = window <= 0 ? 1 : window;
    final averages = <double>[];

    for (var index = 0; index < values.length; index++) {
      final start = index - normalizedWindow + 1;
      final windowStart = start < 0 ? 0 : start;
      final slice = values.sublist(windowStart, index + 1);
      final total = slice.fold<double>(0, (sum, value) => sum + value);
      averages.add(total / slice.length);
    }

    return averages;
  }

  static double latest(List<double> values, {int window = 7}) {
    final averages = calculate(values, window: window);
    return averages.isEmpty ? 0 : averages.last;
  }
}
