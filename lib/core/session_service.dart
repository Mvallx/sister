import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/auth_service.dart';

class Session {
  const Session({required this.userId, required this.role});
  final String userId;
  final UserRole role;
}

/// Menyimpan sesi login di penyimpanan lokal.
/// Catatan: saat backend siap, simpan token di flutter_secure_storage.
class SessionService {
  SessionService._();

  static const _kUserId = 'session_user_id';
  static const _kRole = 'session_role';

  static Future<void> save({
    required String userId,
    required UserRole role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserId, userId);
    await prefs.setString(_kRole, role.name);
  }

  /// Mengembalikan null bila belum login / data rusak.
  static Future<Session?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kUserId);
    final roleName = prefs.getString(_kRole);
    if (id == null || roleName == null) return null;
    try {
      return Session(userId: id, role: UserRole.values.byName(roleName));
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserId);
    await prefs.remove(_kRole);
  }
}
