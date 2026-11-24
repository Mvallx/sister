import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/date_utils.dart';
import '../../core/models.dart';
import '../../core/widgets/app_card.dart';

/// Layar 11 - isi daftar pengajuan izin.
class LeaveRequestsView extends StatelessWidget {
  const LeaveRequestsView({super.key});

  String _range(LeaveRequest l) => sameDay(l.start, l.end)
      ? '${l.start.day} ${monthShort(l.start.month)}'
      : '${l.start.day}–${l.end.day} ${monthShort(l.end.month)}';

  void _preview(BuildContext context, LeaveRequest l) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.attachmentName ?? 'Lampiran'),
        content: l.attachmentPath != null
            ? Image.file(
                File(l.attachmentPath!),
                errorBuilder: (_, __, ___) =>
                    const Text('Pratinjau tidak tersedia di perangkat ini.'),
              )
            : const Text('Pratinjau lampiran contoh (belum ada berkas asli).'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        // Menunggu paling atas, lalu sisanya.
        final sorted = [...state.leaves]..sort((a, b) {
            final wa = a.status == LeaveStatus.menunggu ? 0 : 1;
            final wb = b.status == LeaveStatus.menunggu ? 0 : 1;
            return wa.compareTo(wb);
          });

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: StatTile(
                        value: '${state.leaveCount(LeaveStatus.menunggu)}',
                        label: 'Menunggu')),
                const SizedBox(width: 10),
                Expanded(
                    child: StatTile(
                        value: '${state.leaveCount(LeaveStatus.disetujui)}',
                        label: 'Disetujui')),
                const SizedBox(width: 10),
                Expanded(
                    child: StatTile(
                        value: '${state.leaveCount(LeaveStatus.ditolak)}',
                        label: 'Ditolak')),
              ],
            ),
            const SizedBox(height: 12),
            for (final l in sorted)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(l.studentName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                          StatusBadge(l.status.label, color: l.status.color),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${_range(l)} · ${l.type.longLabel}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                      const SizedBox(height: 8),
                      Text(l.reason, style: const TextStyle(fontSize: 12.5)),
                      if (l.attachmentName != null) ...[
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () => _preview(context, l),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(l.attachmentName!,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryDark)),
                          ),
                        ),
                      ],
                      if (l.status == LeaveStatus.menunggu) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: () =>
                                    state.decideLeave(l, approve: true),
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      AppColors.primary.withOpacity(0.25),
                                  foregroundColor: AppColors.primaryDark,
                                  elevation: 0,
                                ),
                                child: const Text('Setujui'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton(
                                onPressed: () =>
                                    state.decideLeave(l, approve: false),
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      AppColors.alpha.withOpacity(0.3),
                                  foregroundColor: AppColors.error,
                                  elevation: 0,
                                ),
                                child: const Text('Tolak'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
