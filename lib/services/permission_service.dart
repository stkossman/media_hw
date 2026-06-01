import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<PermissionStatus> requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted || status.isPermanentlyDenied) {
      return status;
    }
    return Permission.camera.request();
  }

  Future<PermissionStatus> requestGalleryPermission() async {
    final status = await Permission.photos.status;
    if (status.isGranted || status.isLimited) {
      return PermissionStatus.granted;
    }
    if (status.isPermanentlyDenied) {
      return status;
    }
    final requested = await Permission.photos.request();
    if (requested.isGranted || requested.isLimited) {
      return PermissionStatus.granted;
    }
    return requested;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}
