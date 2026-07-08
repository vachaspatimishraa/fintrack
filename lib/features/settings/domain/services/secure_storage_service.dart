import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _appLockEnabledKey = 'app_lock_enabled';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _timeoutKey = 'app_lock_timeout';
  static const String _lastAuthTimeKey = 'last_auth_time';

  Future<void> saveAppLockEnabled(bool enabled) async {
    await _storage.write(key: _appLockEnabledKey, value: enabled.toString());
  }

  Future<bool> getAppLockEnabled() async {
    final value = await _storage.read(key: _appLockEnabledKey);
    return value == 'true';
  }

  Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  Future<bool> getBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  Future<void> saveTimeout(String timeout) async {
    await _storage.write(key: _timeoutKey, value: timeout);
  }

  Future<String> getTimeout() async {
    return await _storage.read(key: _timeoutKey) ?? 'immediately';
  }

  Future<void> saveLastAuthTime(int timestamp) async {
    await _storage.write(key: _lastAuthTimeKey, value: timestamp.toString());
  }

  Future<int?> getLastAuthTime() async {
    final value = await _storage.read(key: _lastAuthTimeKey);
    return value != null ? int.tryParse(value) : null;
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
