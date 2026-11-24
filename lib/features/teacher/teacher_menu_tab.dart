import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/menu_tile.dart';
import '../../core/widgets/screen_header.dart';
import '../auth/widgets/logout_button.dart';
import 'report_screen.dart';

/// Tab Menu wali kelas: akses Laporan + keluar akun.
class TeacherMenuTab extends StatelessWidget {
  const TeacherMenuTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          const ScreenHeader(title: 'Menu', subtitle: 'Wali kelas XI RPL'),
          const SizedBox(height: 16),
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withOpacity(0.25),
                  child: const Text('W',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark)),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Wali Kelas XI RPL',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('SMK N 1 Bukateja',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: MenuTile(
              title: 'Laporan Kehadiran',
              subtitle: 'Rekap bulanan kelas',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReportScreen()),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const LogoutButton(),
        ],
      ),
    );
  }
}
