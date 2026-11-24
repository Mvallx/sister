import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/date_utils.dart';
import '../../core/models.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/screen_header.dart';

/// Layar 08 - Ringkasan Kelas.
class TeacherSummaryTab extends StatelessWidget {
  const TeacherSummaryTab({super.key, required this.onOpenValidation});

  final VoidCallback onOpenValidation;

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return SafeArea(
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final present = state.presentCount;
          final total = state.totalStudents;

          final actions = <(String, String, VoidCallback?)>[
            for (final l
                in state.leaves.where((l) => l.status == LeaveStatus.menunggu))
              (
                l.studentName,
                'Pengajuan izin ${l.type.longLabel.toLowerCase()}',
                onOpenValidation,
              ),
            for (final s
                in state.students.where((s) => s.missedCheckoutYesterday))
              (s.name, 'Belum absen pulang kemarin', null),
          ];

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              ScreenHeader(
                title: 'Ringkasan Kelas',
                subtitle: 'XI RPL · ${fullDate(AppState.today)}',
                trailing: const StatusBadge('WALI KELAS', color: AppColors.alpha),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('HADIR HARI INI',
                        style: TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                            letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('$present',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.w800)),
                        Text(' / $total',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${total - present} belum absen',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: StatTile(
                          value: '${state.count(AttStatus.terlambat)}',
                          label: 'Terlambat')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: StatTile(
                          value: '${state.count(AttStatus.izin)}',
                          label: 'Izin')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: StatTile(
                          value: '${state.count(AttStatus.alpha)}',
                          label: 'Alpha')),
                ],
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Perlu tindakan',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 10),
                    if (actions.isEmpty)
                      const Text('Tidak ada yang perlu ditindaklanjuti.',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0)
                        const Divider(height: 18, color: AppColors.border),
                      InkWell(
                        onTap: actions[i].$3,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.2),
                              child: const Text('S',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(actions[i].$1,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  Text(actions[i].$2,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            if (actions[i].$3 != null)
                              const Icon(Icons.chevron_right,
                                  color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
