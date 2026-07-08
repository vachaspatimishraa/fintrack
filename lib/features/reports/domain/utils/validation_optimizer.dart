class ValidationOptimizer {
  const ValidationOptimizer();

  bool validateFilePath(String path) {
    if (path.isEmpty) return false;
    // Basic format validation
    final ext = path.split('.').last.toLowerCase();
    return ext == 'pdf' || ext == 'xlsx' || ext == 'csv';
  }

  bool validateFileSize(int sizeBytes) {
    // Report files must not exceed 50 MB to prevent out-of-memory crashes
    const maxSizeBytes = 50 * 1024 * 1024;
    return sizeBytes > 0 && sizeBytes <= maxSizeBytes;
  }
}
