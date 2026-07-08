import 'package:flutter/services.dart';

class ScreenshotProtectionService {
  static const MethodChannel _channel = MethodChannel('com.fintrack.app/security');

  static Future<void> setEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod('setScreenshotProtection', {'enabled': enabled});
    } catch (e) {
      // Platform not supported or error
    }
  }
}
