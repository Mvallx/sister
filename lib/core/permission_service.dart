import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

enum PermState { granted, denied, permanentlyDenied }

/// Pembungkus permission_handler (kamera & lokasi).
class PermissionService {
  PermissionService._();

  /// permission_handler hanya relevan di Android/iOS.
  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static Future<PermState> _ensure(Permission p) async {
    if (!isSupported) return PermState.granted;
    var s = await p.status;
    if (s.isDenied) s = await p.request();
    if (s.isGranted || s.isLimited) return PermState.granted;
    if (s.isPermanentlyDenied || s.isRestricted) {
      return PermState.permanentlyDenied;
    }
    return PermState.denied;
  }

  static Future<PermState> ensureCamera() => _ensure(Permission.camera);

  static Future<PermState> ensureLocation() =>
      _ensure(Permission.locationWhenInUse);

  /// Dipanggil sekali saat siswa masuk Beranda.
  static Future<void> requestAll() async {
    await ensureCamera();
    await ensureLocation();
  }

  static Future<bool> openSettings() => openAppSettings();
}
