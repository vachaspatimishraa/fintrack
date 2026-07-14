import 'dart:io';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  static const _channel = MethodChannel('com.fintrack.app/security');

  Future<bool> isBiometricAvailable() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate({
    String reason = 'Please authenticate to access FinTrack',
    bool biometricEnabled = true,
  }) async {
    try {
      if (!biometricEnabled && Platform.isAndroid) {
        final result = await _channel.invokeMethod<bool>(
          'authenticateDeviceCredential',
          {
            'title': 'Security Verification',
            'description': reason,
          },
        );
        return result ?? false;
      }

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Must be false to allow device credentials (PIN/pattern/password)
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return <BiometricType>[];
    }
  }
}
