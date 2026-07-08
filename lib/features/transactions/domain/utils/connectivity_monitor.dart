import 'dart:async';
import 'dart:io';

class ConnectivityMonitor {
  static final ConnectivityMonitor _instance = ConnectivityMonitor._internal();
  factory ConnectivityMonitor() => _instance;
  ConnectivityMonitor._internal();

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _lastState = true;

  Stream<bool> get onConnectivityChanged => _controller.stream;

  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 3));
      final isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (isOnline != _lastState) {
        _lastState = isOnline;
        _controller.add(isOnline);
      }
      return isOnline;
    } catch (_) {
      if (_lastState) {
        _lastState = false;
        _controller.add(false);
      }
      return false;
    }
  }
}
