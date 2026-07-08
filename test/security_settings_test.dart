import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/settings/domain/services/session_manager.dart';
import 'package:fintrack/features/settings/domain/services/secure_storage_service.dart';

class FakeSecureStorageService implements SecureStorageService {
  int? _lastAuthTime;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> saveLastAuthTime(int timestamp) async {
    _lastAuthTime = timestamp;
  }

  @override
  Future<int?> getLastAuthTime() async {
    return _lastAuthTime;
  }
}

void main() {
  group('SessionManager', () {
    test('shouldLock should return true after timeout', () async {
      final fakeStorage = FakeSecureStorageService();
      final manager = SessionManager(fakeStorage);
      await manager.updateActivity();
      
      expect(await manager.shouldLock('immediately'), isTrue);
      expect(await manager.shouldLock('never'), isFalse);
    });

    test('shouldLock should handle null last activity', () async {
      final fakeStorage = FakeSecureStorageService();
      final manager = SessionManager(fakeStorage);
      expect(await manager.shouldLock('immediately'), isFalse);
    });
  });
}
