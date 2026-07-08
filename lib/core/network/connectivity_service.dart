import 'dart:async';
import 'dart:io';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  ConnectivityService._internal() {
    _startMonitoring();
  }

  final _controller = StreamController<bool>.broadcast();
  bool _isConnected = false;
  Timer? _timer;

  Stream<bool> get onConnectivityChanged => _controller.stream;
  bool get isConnected => _isConnected;

  void _startMonitoring() {
    _checkStatus();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkStatus());
  }

  Future<bool> checkConnection() async {
    await _checkStatus();
    return _isConnected;
  }

  Future<void> _checkStatus() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      final connected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (connected != _isConnected) {
        _isConnected = connected;
        _controller.add(_isConnected);
      }
    } catch (_) {
      if (_isConnected) {
        _isConnected = false;
        _controller.add(false);
      }
    }
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
