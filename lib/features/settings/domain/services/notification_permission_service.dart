import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionService {
  Future<PermissionStatus> getStatus() async {
    return await Permission.notification.status;
  }

  Future<PermissionStatus> requestPermission() async {
    return await Permission.notification.request();
  }

  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
