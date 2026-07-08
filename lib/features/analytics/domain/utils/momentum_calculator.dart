class MomentumCalculator {
  const MomentumCalculator._();

  static double calculate(List<double> values) {
    if (values.length < 3) return 0;
    final latestVelocity = values.last - values[values.length - 2];
    final previousVelocity = values[values.length - 2] - values[values.length - 3];
    return latestVelocity - previousVelocity;
  }

  static double confidence(List<double> values) {
    if (values.length < 3) return 0;
    final increases = <bool>[];
    for (var index = 1; index < values.length; index++) {
      increases.add(values[index] >= values[index - 1]);
    }
    final dominant = increases.where((value) => value == increases.last).length;
    return dominant / increases.length;
  }
}
