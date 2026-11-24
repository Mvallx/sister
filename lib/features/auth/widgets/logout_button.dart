import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_routes.dart';
import '../../../core/session_service.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu perlu login lagi untuk memakai Hadirku.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await SessionService.clear(); // hapus sesi tersimpan
    if (!context.mounted) return;

    // Kosongkan seluruh stack, sisakan hanya Login.
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: () => _logout(context),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.alpha.withOpacity(0.25),
          foregroundColor: AppColors.error,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
        child: const Text('Keluar dari akun'),
      ),
    );
  }
}
