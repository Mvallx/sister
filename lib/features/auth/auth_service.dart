enum UserRole { siswa, waliKelas }

class AuthResult {
  const AuthResult.success(this.role)
      : success = true,
        message = null;
  const AuthResult.failure(this.message)
      : success = false,
        role = null;

  final bool success;
  final UserRole? role;
  final String? message;
}

/// Simulasi autentikasi. Ganti isi [login] dengan panggilan REST API
/// saat backend sudah tersedia (Tahap 9).
class AuthService {
  /// Aturan simulasi:
  /// - NIS hanya angka (mis. 12316)        -> siswa
  /// - ID guru diawali "G" (mis. GURU01)   -> wali kelas
  /// - Kata sandi minimal 6 karakter
  Future<AuthResult> login({
    required String id,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final value = id.trim();
    if (password.length < 6) {
      return const AuthResult.failure('NIS/ID atau kata sandi salah.');
    }
    if (RegExp(r'^[0-9]+$').hasMatch(value)) {
      return const AuthResult.success(UserRole.siswa);
    }
    if (RegExp(r'^[Gg][A-Za-z0-9]+$').hasMatch(value)) {
      return const AuthResult.success(UserRole.waliKelas);
    }
    return const AuthResult.failure('NIS/ID atau kata sandi salah.');
  }
}
