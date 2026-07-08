class VelocityCalculator {
  const VelocityCalculator._();

  static double calculate(double current, double previous) {
    return current - previous;
  }

  static String describe(double velocity, {double stableThreshold = 1}) {
    if (velocity.abs() <= stableThreshold) return 'Stable';
    return velocity > 0 ? 'Increasing' : 'Decreasing';
  }
}
