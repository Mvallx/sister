import 'dart:async';
import 'dart:math' as math;

import 'package:location/location.dart' as loc;

import 'permission_service.dart';
import 'school_config.dart';

enum LocationStatus {
  ready, // koordinat didapat
  simulated, // platform tanpa GPS (desktop/web)
  serviceDisabled,
  denied,
  deniedForever,
  fakeGps,
  unavailable,
}

class LocationCheck {
  const LocationCheck({
    required this.status,
    this.distanceMeters,
    this.insideSchool = false,
  });

  final LocationStatus status;
  final double? distanceMeters;
  final bool insideSchool;

  bool get canAbsen =>
      status == LocationStatus.simulated ||
      (status == LocationStatus.ready &&
          (insideSchool || !SchoolConfig.enforceRadius));

  String get message {
    final d = distanceMeters?.round();
    switch (status) {
      case LocationStatus.ready:
        return insideSchool
            ? 'Area ${SchoolConfig.name} ($d m dari titik sekolah)'
            : 'Di luar area sekolah ($d m dari titik sekolah)';
      case LocationStatus.simulated:
        return 'Area ${SchoolConfig.name} (simulasi)';
      case LocationStatus.serviceDisabled:
        return 'Lokasi/GPS di HP belum aktif';
      case LocationStatus.denied:
        return 'Izin lokasi ditolak';
      case LocationStatus.deniedForever:
        return 'Izin lokasi diblokir, buka Pengaturan';
      case LocationStatus.fakeGps:
        return 'Lokasi palsu (fake GPS) terdeteksi';
      case LocationStatus.unavailable:
        return 'Lokasi belum bisa dibaca, coba lagi';
    }
  }
}

/// Deteksi lokasi memakai paket `location` + izin dari `permission_handler`.
class LocationService {
  LocationService._();

  static Future<LocationCheck> check() async {
    if (!PermissionService.isSupported) {
      return const LocationCheck(
        status: LocationStatus.simulated,
        insideSchool: true,
      );
    }
    try {
      final perm = await PermissionService.ensureLocation();
      if (perm == PermState.permanentlyDenied) {
        return const LocationCheck(status: LocationStatus.deniedForever);
      }
      if (perm != PermState.granted) {
        return const LocationCheck(status: LocationStatus.denied);
      }

      final l = loc.Location();
      var enabled = await l.serviceEnabled();
      if (!enabled) {
        enabled = await l.requestService();
        if (!enabled) {
          return const LocationCheck(status: LocationStatus.serviceDisabled);
        }
      }
      await l.changeSettings(accuracy: loc.LocationAccuracy.high);
      final data = await l.getLocation().timeout(const Duration(seconds: 15));

      if (data.isMock == true) {
        return const LocationCheck(status: LocationStatus.fakeGps);
      }
      final lat = data.latitude;
      final lng = data.longitude;
      if (lat == null || lng == null) {
        return const LocationCheck(status: LocationStatus.unavailable);
      }

      final d = _distanceMeters(
          lat, lng, SchoolConfig.latitude, SchoolConfig.longitude);
      return LocationCheck(
        status: LocationStatus.ready,
        distanceMeters: d,
        insideSchool: d <= SchoolConfig.radiusMeters,
      );
    } on TimeoutException {
      return const LocationCheck(status: LocationStatus.unavailable);
    } catch (_) {
      return const LocationCheck(status: LocationStatus.unavailable);
    }
  }

  /// Jarak dua titik (rumus Haversine), hasil dalam meter.
  static double _distanceMeters(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    double rad(double d) => d * math.pi / 180;
    final dLat = rad(lat2 - lat1);
    final dLon = rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rad(lat1)) *
            math.cos(rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return 2 * r * math.asin(math.sqrt(a));
  }
}
