class GoalSyncStatus {
  final bool isSyncing;
  final DateTime? lastSyncAt;
  final int pendingItems;
  final String? error;

  const GoalSyncStatus({
    required this.isSyncing,
    this.lastSyncAt,
    required this.pendingItems,
    this.error,
  });
}
