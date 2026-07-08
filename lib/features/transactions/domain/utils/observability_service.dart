class ObservabilityService {
  static String determineHealthState(double crashRate) {
    if (crashRate < 0.002) return 'Healthy';
    if (crashRate < 0.02) return 'Warning';
    return 'Critical';
  }
}
