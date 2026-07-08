class RetryManager {
  static const int maxRetries = 20;

  static Duration getNextDelay(int attempt) {
    if (attempt <= 0) return Duration.zero;
    if (attempt > 6) return const Duration(minutes: 32);

    // Exponential delay: 1, 2, 4, 8, 16, 32 minutes
    final minutes = 1 << (attempt - 1);
    return Duration(minutes: minutes);
  }

  static bool shouldRetry(int attempt) {
    return attempt < maxRetries;
  }
}
