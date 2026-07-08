import 'connectivity_service.dart';

class NetworkInfo {
  final ConnectivityService _connectivityService = ConnectivityService();

  Future<bool> get isConnected => _connectivityService.checkConnection();
}
