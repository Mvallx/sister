import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/date_utils.dart';
import '../../core/models.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/menu_tile.dart';
import '../../core/widgets/screen_header.dart';
import '../auth/widgets/logout_button.dart';

/// Layar 07 - Akun Saya (profil siswa).
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  void _info(BuildContext context, String title, List<String> lines) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [for (final l in lines) Text(l)],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
  }

  void _leaveSheet(BuildContext context) {
    final list = AppState.instance.myLeaves;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Status pengajuan izin',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 12),
              if (list.isEmpty)
                const Text('Belum ada pengajuan.',
                    style: TextStyle(color: AppColors.textMuted)),
              for (final l in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${l.type.longLabel} · ${shortDate(l.start)}'
                          '${sameDay(l.start, l.end) ? '' : ' – ${shortDate(l.end)}'}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      StatusBadge(l.status.label, color: l.status.color),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _settingsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('Pengaturan (uji coba)',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: const Text('Reset absen hari ini'),
              subtitle: const Text('Supaya bisa mencoba absen berangkat lagi'),
              onTap: () {
                AppState.instance.clearMyToday();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined),
              title: const Text('Reset semua data contoh'),
              onTap: () {
                AppState.instance.resetAll();
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final pending = AppState.instance.myPendingCount;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              const ScreenHeader(title: 'Akun Saya', subtitle: 'Data siswa'),
              const SizedBox(height: 16),
              AppCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withOpacity(0.25),
                      child: const Text('M',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark)),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppState.studentName,
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        Text('XI RPL · Absen ${AppState.studentNumber}',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  children: [
                    MenuTile(
                      title: 'Data diri',
                      subtitle: 'NIS, tempat tanggal lahir',
                      onTap: () => _info(context, 'Data diri', const [
                        'Nama: ${AppState.studentName}',
                        'NIS: ${AppState.studentNis}',
                        'TTL: (diisi dari data sekolah)',
                      ]),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    MenuTile(
                      title: 'Kelas & wali kelas',
                      subtitle: 'XI RPL · Nama Wali Kelas',
                      onTap: () => _info(context, 'Kelas & wali kelas', const [
                        'Kelas: XI RPL',
                        'Wali kelas: (diisi dari data sekolah)',
                      ]),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    MenuTile(
                      title: 'Status pengajuan izin',
                      subtitle: '$pending menunggu',
                      onTap: () => _leaveSheet(context),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    MenuTile(
                      title: 'Pengaturan',
                      subtitle: 'Pengingat dan keamanan',
                      onTap: () => _settingsSheet(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const LogoutButton(),
            ],
          );
        },
      ),
    );
  }
}
