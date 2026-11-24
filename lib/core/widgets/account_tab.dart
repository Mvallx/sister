import 'package:flutter/material.dart';

import '../../features/auth/widgets/logout_button.dart';
import '../app_colors.dart';
import 'app_card.dart';

/// Kerangka tab Akun (siswa, Layar 07) / Menu (wali kelas) dengan tombol keluar.
class AccountTab extends StatelessWidget {
  const AccountTab({
    super.key,
    required this.title,
    required this.name,
    required this.subtitle,
  });

  final String title;
  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withOpacity(0.25),
                  child: Text(
                    name.isEmpty ? '?' : name[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const LogoutButton(),
        ],
      ),
    );
  }
}
