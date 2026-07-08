import 'secure_storage_service.dart';

class SessionManager {
  final SecureStorageService _storage;
  DateTime? _lastActivity;
  bool _isLocked = false;

  SessionManager(this._storage);

  bool get isLocked => _isLocked;

  Future<void> updateActivity() async {
    final now = DateTime.now();
    _lastActivity = now;
    await _storage.saveLastAuthTime(now.millisecondsSinceEpoch);
  }

  void lock() {
    _isLocked = true;
  }

  Future<void> unlock() async {
    _isLocked = false;
    await updateActivity();
  }

  Future<bool> shouldLock(String timeoutPreference) async {
    if (_lastActivity == null) {
      final savedTime = await _storage.getLastAuthTime();
      if (savedTime != null) {
        _lastActivity = DateTime.fromMillisecondsSinceEpoch(savedTime);
      }
    }

    if (_lastActivity == null) return false;

    final duration = DateTime.now().difference(_lastActivity!);
    final timeout = _getDurationFromPreference(timeoutPreference);

    if (timeout == null) return false;
    return duration >= timeout;
  }

  Duration? _getDurationFromPreference(String preference) {
    switch (preference) {
      case 'immediately':
        return Duration.zero;
      case '1_min':
        return const Duration(minutes: 1);
      case '5_min':
        return const Duration(minutes: 5);
      case '15_min':
        return const Duration(minutes: 15);
      case '30_min':
        return const Duration(minutes: 30);
      case '1_hour':
        return const Duration(hours: 1);
      case 'never':
      default:
        return null;
    }
  }
}
