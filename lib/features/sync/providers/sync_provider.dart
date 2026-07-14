import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/utils/sync_preferences.dart';
import '../../splash/providers/initialization_provider.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() {
    // Keep it alive, but if disposed, clean up
  });
  return service;
});

final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});

final syncServiceProvider = Provider<SyncService>((ref) {
  // SyncService will require Isar, SupabaseClient, and ConnectivityService.
  // We can pass them to the SyncService constructor or retrieve them.
  final isarService = ref.watch(isarInitializationServiceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  
  // Return a SyncService initialized with the needed dependencies.
  return SyncService(
    isar: isarService.isar,
    connectivity: connectivity,
  );
});

// A StateNotifier to hold the sync state (isSyncing, pendingCount, lastSyncTime, errorMessage)
class SyncState {
  final bool isSyncing;
  final int pendingCount;
  final DateTime? lastSyncTime;
  final String? errorMessage;

  SyncState({
    required this.isSyncing,
    required this.pendingCount,
    this.lastSyncTime,
    this.errorMessage,
  });

  SyncState copyWith({
    bool? isSyncing,
    int? pendingCount,
    DateTime? lastSyncTime,
    String? errorMessage,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  final SyncService _syncService;
  final Ref _ref;

  SyncNotifier(this._syncService, this._ref) : super(SyncState(isSyncing: false, pendingCount: 0)) {
    _init();
  }

  void _init() async {
    // Load initial sync timestamp
    final initialLastSync = await SyncPreferences.getLastSync();
    state = state.copyWith(lastSyncTime: initialLastSync);

    // Watch pending counts or listen to the sync service status
    _syncService.onPendingCountChanged.listen((count) {
      state = state.copyWith(pendingCount: count);
    });
    _syncService.onSyncStatusChanged.listen((isSyncing) async {
      state = state.copyWith(isSyncing: isSyncing);
      if (!isSyncing) {
        final lastSync = await SyncPreferences.getLastSync();
        state = state.copyWith(lastSyncTime: lastSync);
        _ref.invalidate(lastSyncProvider);
      }
    });
  }

  Future<void> triggerSync() async {
    state = state.copyWith(isSyncing: true, errorMessage: null);
    try {
      await _syncService.triggerSync();
      final lastSync = await SyncPreferences.getLastSync();
      state = state.copyWith(isSyncing: false, lastSyncTime: lastSync);
      _ref.invalidate(lastSyncProvider);
    } catch (e) {
      state = state.copyWith(isSyncing: false, errorMessage: e.toString());
    }
  }
}

final syncStatusProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return SyncNotifier(syncService, ref);
});

final lastSyncProvider = FutureProvider<DateTime?>((ref) async {
  return SyncPreferences.getLastSync();
});
