class Failure {
  final String code;
  final String message;
  final String action;
  final bool isRetryAvailable;

  const Failure({
    required this.code,
    required this.message,
    required this.action,
    this.isRetryAvailable = false,
  });

  @override
  String toString() => 'Failure[$code]: $message';
}
