import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import 'auth_service.dart';
import 'widgets/brand_logo.dart';
import 'widgets/hadirku_text_field.dart';
import 'widgets/primary_button.dart';

/// Layar 01 - Login Siswa & Wali Kelas.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _authService = AuthService();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    final result = await _authService.login(
      id: _idController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Terjadi kesalahan.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    final route = result.role == UserRole.siswa
        ? AppRoutes.studentHome // Layar 02
        : AppRoutes.teacherSummary; // Layar 08
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: BrandLogo()),
                    const SizedBox(height: 40),
                    HadirkuTextField(
                      label: 'NIS / ID GURU',
                      hint: 'Masukkan NIS',
                      controller: _idController,
                      enabled: !_loading,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'NIS / ID guru wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    HadirkuTextField(
                      label: 'KATA SANDI',
                      hint: 'Masukkan kata sandi',
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      enabled: !_loading,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Kata sandi wajib diisi'
                          : null,
                      suffixIcon: IconButton(
                        tooltip: _obscure ? 'Tampilkan' : 'Sembunyikan',
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Masuk',
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Akun dibuat oleh sekolah · Lupa sandi? Hubungi tata usaha',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
